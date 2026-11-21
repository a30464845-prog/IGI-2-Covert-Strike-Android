using ProjectIGI.Core.Graphics;

namespace ProjectIGI.Frontend.Ui;

/// <summary>
/// The shell remake's shared design tokens: one accent blue, opaque dark panels, and the 48 dp
/// minimum everything tappable is built to.
/// </summary>
/// <remarks>
/// <para>
/// Pinned by the UI remake design system (DESIGN.md). The literals here are authoritative: every
/// remade surface uses these exact values, and a follow-up unification pass swaps the literals the
/// surfaces were built with for these tokens once the surfaces merge.
/// </para>
/// <para>
/// Panels are opaque — no glass, no glow, no shimmer. Text contrast is 4.5:1 or better on the panel.
/// Sizes are shell design units at the 1080p-high reference (Scale 1.2), where 48 dp is ≈104 units;
/// a screen on a different reference recomputes the 48 dp equivalent from its own scale instead of
/// pasting 104. Touch buttons are physical pixels 1:1 at 1080p, so their radius is in px, not units.
/// </para>
/// </remarks>
public static class ShellDesign
{
    /// <summary>The one accent blue, everywhere in the shell and launcher: <c>#50A0FF</c>.</summary>
    public static Bgra32 Accent => Bgra32.FromRgb(80, 160, 255);

    /// <summary>An opaque panel: <c>#08101E</c>, alpha 255. No glass.</summary>
    public static Bgra32 Panel => Bgra32.FromRgb(8, 16, 30);

    /// <summary>A panel's hairline border: the accent blue, drawn <see cref="PanelHairlineUnits"/> wide.</summary>
    public static Bgra32 PanelBorder => Bgra32.FromRgb(80, 160, 255);

    /// <summary>Primary text: <c>#EBF2FA</c>.</summary>
    public static Bgra32 TextPrimary => Bgra32.FromRgb(235, 242, 250);

    /// <summary>Secondary text: <c>#96AFBE</c> — 6.87:1 on the dark panel.</summary>
    public static Bgra32 TextSecondary => Bgra32.FromRgb(150, 175, 190);

    /// <summary>Dark text punched out of an accent fill: <c>#090E1C</c>.</summary>
    public static Bgra32 TextOnAccent => Bgra32.FromRgb(9, 14, 28);

    /// <summary>Success, ready, a fix: a real green, never the accent blue: <c>#50C878</c>.</summary>
    public static Bgra32 Success => Bgra32.FromRgb(80, 200, 120);

    /// <summary>An error, a destructive action: the Abort red: <c>#FF5F50</c>.</summary>
    public static Bgra32 Danger => Bgra32.FromRgb(255, 95, 80);

    /// <summary>The minimum tappable size, in dp.</summary>
    public const float MinTouchTargetDp = 48f;

    /// <summary>
    /// The minimum height of a shell row or button, in design units at the 1080p-high reference
    /// (Scale 1.2): 48 dp. Recompute from the screen's own scale on any other reference.
    /// </summary>
    public const float MinRowHeightUnits = 104f;

    /// <summary>The width of a panel's accent hairline, in design units.</summary>
    public const float PanelHairlineUnits = 1.5f;

    /// <summary>The size of the on-screen back control, in dp; it sits top-left on every shell screen.</summary>
    public const float BackControlDp = 48f;

    /// <summary>The minimum radius of a touch button, in physical px (1:1 at 1080p): 48 dp.</summary>
    public const float MinTouchButtonRadiusPx = 63f;

    /// <summary>The Fire button's radius, in physical px: unchanged, already above the minimum.</summary>
    public const float FireButtonRadiusPx = 80f;

    /// <summary>The launcher's minimum text size, in sp.</summary>
    public const float MinLauncherTextSp = 12f;
}
