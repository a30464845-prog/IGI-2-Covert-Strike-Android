using ProjectIGI.Core.Numerics;
using ProjectIGI.Formats.World;
using ProjectIGI.Game.Igi2.World;
using ProjectIGI.Game.Player;

namespace ProjectIGI.Game.Igi2.ViewModel;

/// <summary>The rigid models nested under a held model, <c>modelobj.c ModelObj_CreateAttachObjects</c>.</summary>
/// <param name="models">The mission's models.</param>
/// <param name="magic">The configured magic-object types.</param>
public sealed class Igi2ModelAttachments(Func<string, MefModel?> models, Igi2MagicObjTypes? magic)
{
    /// <summary>Resolves an animation or model attachment through <c>magicobj.c MagicObj_GetMagicObjType</c>.</summary>
    /// <param name="name">The attachment name.</param>
    /// <returns>The configured model, its own name when unconfigured, or null for a marker or shadow.</returns>
    public string? ModelOf(string name) => magic is null ? name : magic.ModelOf(name);

    /// <summary>Expands a rigid model's complete attachment tree in the view's local frame.</summary>
    /// <param name="part">The root part, which is also returned.</param>
    /// <param name="suppressed">The models the clip already hangs, whose nested copies are not drawn, or <see langword="null"/> for none.</param>
    /// <returns>The root and its drawable children, in creation order.</returns>
    public IEnumerable<TitleViewModelPart> Expand(TitleViewModelPart part, IReadOnlySet<string>? suppressed = null)
    {
        ArgumentNullException.ThrowIfNull(part);
        return Walk(part, new HashSet<string>(StringComparer.OrdinalIgnoreCase), suppressed);
    }

    private IEnumerable<TitleViewModelPart> Walk(TitleViewModelPart part, HashSet<string> ancestors, IReadOnlySet<string>? suppressed)
    {
        yield return part;
        if (part.Pose is not null || ancestors.Count >= 16 || !ancestors.Add(part.Model))
        {
            yield break;
        }

        if (models(part.Model) is { } model)
        {
            Igi2Pose parent = Igi2Pose.FromMatrix(new Vector3d(part.Position.X, part.Position.Y, part.Position.Z), part.Orientation);
            foreach (MefAttachment attachment in model.Attachments)
            {
                // modelobj.c ModelObj_CreateAttachObject: names are resolved through MagicObj_GetMagicObjType;
                // unknown names are rigid models, while configured "none" and shadows draw nothing. A model the
                // clip hangs on the pose itself is drawn where the clip puts it: its rigid nested copy would sit
                // stuck in the weapon while the clip's copy moves, as a magazine does over a reload clip.
                string? name = ModelOf(attachment.Name);
                if (string.IsNullOrEmpty(name) || string.Equals(name, Igi2MagicObjTypes.NoModel, StringComparison.Ordinal)
                    || (suppressed is not null && suppressed.Contains(name)))
                {
                    continue;
                }

                Igi2Pose child = parent.Attach(attachment);
                TitleViewModelPart attached = new(name, null,
                    new Vector3f((float)child.Position.X, (float)child.Position.Y, (float)child.Position.Z), child.ToMatrix());
                foreach (TitleViewModelPart nested in Walk(attached, ancestors, suppressed))
                {
                    yield return nested;
                }
            }
        }

        ancestors.Remove(part.Model);
    }
}
