using ProjectIGI.Core.Numerics;
using ProjectIGI.Engine.Tasks;
using ProjectIGI.Game.Igi2.Interaction;
using ProjectIGI.Game.World;

namespace ProjectIGI.Game.Igi2.World;

/// <summary>
/// How an object is held to the parent that carries it, <c>ModelObj</c>'s <c>tRelativePos</c> and <c>tRelativeOrientation</c>: kept
/// when it attaches, and turned back into the world each time the parent moves.
/// </summary>
/// <remarks>
/// <para>
/// Attaching (<c>ModelObj_CalcRelativePosAndOrientation</c>, <c>igi2 0x56C9B0</c>, as <c>Door_AttachToParent</c> does at
/// <c>0x536520</c>): its frame against the parent's is the parent's transpose times its own, and its place against the parent's
/// is the offset turned back into the parent.
/// </para>
/// <para>
/// Following (<c>ModelObj_UpdateAttachment</c>, <c>0x56CB40</c>, its unboned path): its frame is the parent's times what it kept,
/// and its place is the parent's with what it kept turned by the parent. Each sum is made in the order the original makes it.
/// </para>
/// </remarks>
public sealed class Igi2Attachment
{
    private readonly float[] _relativeOrientation = new float[9];
    private Vector3f _relativePosition;

    /// <summary>Gets the parent it is held to, or <see langword="null"/> while it is held to none.</summary>
    public IAttachParent? Parent { get; private set; }

    /// <summary>Holds an object to a parent as the two now stand.</summary>
    /// <param name="parent">The parent, or <see langword="null"/> to hold it to none.</param>
    /// <param name="position">Where the object stands.</param>
    /// <param name="frame">Which way it faces, row by row.</param>
    public void Attach(IAttachParent? parent, Vector3d position, IReadOnlyList<float> frame)
    {
        ArgumentNullException.ThrowIfNull(frame);
        Parent = parent;
        if (parent is null)
        {
            return;
        }

        IReadOnlyList<float> p = parent.AttachOrientation;
        for (int i = 0; i < 3; i++)
        {
            for (int c = 0; c < 3; c++)
            {
                _relativeOrientation[(3 * i) + c] = ((((Fpu)p[i] * frame[c]) + ((Fpu)p[6 + i] * frame[6 + c])) + ((Fpu)p[3 + i] * frame[3 + c])).F;
            }
        }

        Vector3d at = parent.AttachPosition;
        float r0 = ((Fpu)position.X - at.X).F, r1 = ((Fpu)position.Y - at.Y).F, r2 = ((Fpu)position.Z - at.Z).F;
        _relativePosition = new Vector3f(
            ((((Fpu)p[0] * r0) + ((Fpu)p[3] * r1)) + ((Fpu)p[6] * r2)).F,
            ((((Fpu)p[1] * r0) + ((Fpu)p[4] * r1)) + ((Fpu)p[7] * r2)).F,
            ((((Fpu)p[2] * r0) + ((Fpu)p[5] * r1)) + ((Fpu)p[8] * r2)).F);
    }

    /// <summary>Where the parent now holds the object.</summary>
    /// <param name="position">Receives where it stands.</param>
    /// <returns><see langword="false"/> while it is held to no parent.</returns>
    public bool TryResolve(out Vector3d position)
    {
        if (Parent is not { } parent)
        {
            position = default;
            return false;
        }

        IReadOnlyList<float> p = parent.AttachOrientation;
        Vector3f r = _relativePosition;
        float tx = ((((Fpu)p[1] * r.Y) + ((Fpu)r.X * p[0])) + ((Fpu)p[2] * r.Z)).F;
        float ty = ((((Fpu)r.X * p[3]) + ((Fpu)r.Z * p[5])) + ((Fpu)p[4] * r.Y)).F;
        float tz = ((((Fpu)p[7] * r.Y) + ((Fpu)p[6] * r.X)) + ((Fpu)p[8] * r.Z)).F;
        Vector3d at = parent.AttachPosition;
        position = new Vector3d(((Fpu)tx + at.X).Value, ((Fpu)ty + at.Y).Value, ((Fpu)tz + at.Z).Value);
        return true;
    }

    /// <summary>Where the parent now holds the object, and which way.</summary>
    /// <param name="position">Receives where it stands.</param>
    /// <param name="frame">Receives which way it faces, row by row.</param>
    /// <returns><see langword="false"/> while it is held to no parent.</returns>
    public bool TryResolve(out Vector3d position, out float[] frame)
    {
        if (!TryResolve(out position) || Parent is not { } parent)
        {
            frame = [];
            return false;
        }

        IReadOnlyList<float> p = parent.AttachOrientation;
        float[] a = _relativeOrientation;
        frame =
        [
            ((((Fpu)p[2] * a[6]) + ((Fpu)p[1] * a[3])) + ((Fpu)a[0] * p[0])).F,
            ((((Fpu)p[0] * a[1]) + ((Fpu)p[2] * a[7])) + ((Fpu)p[1] * a[4])).F,
            ((((Fpu)p[2] * a[8]) + ((Fpu)p[1] * a[5])) + ((Fpu)p[0] * a[2])).F,
            ((((Fpu)a[6] * p[5]) + ((Fpu)a[3] * p[4])) + ((Fpu)a[0] * p[3])).F,
            ((((Fpu)a[7] * p[5]) + ((Fpu)a[4] * p[4])) + ((Fpu)a[1] * p[3])).F,
            ((((Fpu)p[3] * a[2]) + ((Fpu)p[5] * a[8])) + ((Fpu)p[4] * a[5])).F,
            ((((Fpu)p[8] * a[6]) + ((Fpu)p[7] * a[3])) + ((Fpu)p[6] * a[0])).F,
            ((((Fpu)p[6] * a[1]) + ((Fpu)p[8] * a[7])) + ((Fpu)p[7] * a[4])).F,
            ((((Fpu)p[8] * a[8]) + ((Fpu)p[7] * a[5])) + ((Fpu)p[6] * a[2])).F,
        ];
        return true;
    }

    /// <summary>Where the parent now holds the object, blended between the parent's last two ticks.</summary>
    /// <param name="blend">How far the frame is between the parent's last two ticks, 0–1.</param>
    /// <param name="position">Receives where it stands.</param>
    /// <param name="frame">Receives which way it faces, row by row.</param>
    /// <returns>
    /// <see langword="false"/> while it is held to no parent, or while the parent is not a mover (nothing to
    /// blend between); the caller then falls back to the object's own track.
    /// </returns>
    /// <remarks>
    /// A figure carried by a moving parent (a pilot in a helicopter seat) is drawn from the parent's blended
    /// transform, not from its own per-tick track: the track only spans consecutive ticks, and a catch-up burst
    /// (several ticks between renders, routine below 30 fps) snaps it to the newest tick while the parent still
    /// blends, which slides the figure out of its seat by up to a tick-step. The parent's Last/Current always
    /// span the last two ticks, so the carrier-derived pose follows the hull exactly at any tick gap. The sums
    /// are the same as <see cref="TryResolve(out Vector3d, out float[])"/>'s, in the order the original makes
    /// them, with the parent's blended transform in place of its current one.
    /// </remarks>
    public bool TryResolveBlended(float blend, out Vector3d position, out float[] frame)
    {
        if (Parent is not IIgi2Mover mover)
        {
            position = default;
            frame = [];
            return false;
        }

        // The parent's blended transform, exactly as its own draw blends it: the position lerped
        // Last to Current, the orientation's nine floats lerped the same way.
        float b = Math.Clamp(blend, 0f, 1f);
        IReadOnlyList<float> last = mover.LastOrientation;
        IReadOnlyList<float> current = mover.CurrentOrientation;
        float[] p =
        [
            last[0] + ((current[0] - last[0]) * b),
            last[1] + ((current[1] - last[1]) * b),
            last[2] + ((current[2] - last[2]) * b),
            last[3] + ((current[3] - last[3]) * b),
            last[4] + ((current[4] - last[4]) * b),
            last[5] + ((current[5] - last[5]) * b),
            last[6] + ((current[6] - last[6]) * b),
            last[7] + ((current[7] - last[7]) * b),
            last[8] + ((current[8] - last[8]) * b),
        ];
        Vector3d lastPosition = mover.LastPosition;
        Vector3d currentPosition = mover.CurrentPosition;
        double t = b;
        Vector3d at = new(
            lastPosition.X + ((currentPosition.X - lastPosition.X) * t),
            lastPosition.Y + ((currentPosition.Y - lastPosition.Y) * t),
            lastPosition.Z + ((currentPosition.Z - lastPosition.Z) * t));

        Vector3f r = _relativePosition;
        float tx = ((((Fpu)p[1] * r.Y) + ((Fpu)r.X * p[0])) + ((Fpu)p[2] * r.Z)).F;
        float ty = ((((Fpu)r.X * p[3]) + ((Fpu)r.Z * p[5])) + ((Fpu)p[4] * r.Y)).F;
        float tz = ((((Fpu)p[7] * r.Y) + ((Fpu)p[6] * r.X)) + ((Fpu)p[8] * r.Z)).F;
        position = new Vector3d(((Fpu)tx + at.X).Value, ((Fpu)ty + at.Y).Value, ((Fpu)tz + at.Z).Value);

        float[] a = _relativeOrientation;
        frame =
        [
            ((((Fpu)p[2] * a[6]) + ((Fpu)p[1] * a[3])) + ((Fpu)a[0] * p[0])).F,
            ((((Fpu)p[0] * a[1]) + ((Fpu)p[2] * a[7])) + ((Fpu)p[1] * a[4])).F,
            ((((Fpu)p[2] * a[8]) + ((Fpu)p[1] * a[5])) + ((Fpu)p[0] * a[2])).F,
            ((((Fpu)a[6] * p[5]) + ((Fpu)a[3] * p[4])) + ((Fpu)a[0] * p[3])).F,
            ((((Fpu)a[7] * p[5]) + ((Fpu)a[4] * p[4])) + ((Fpu)a[1] * p[3])).F,
            ((((Fpu)p[3] * a[2]) + ((Fpu)p[5] * a[8])) + ((Fpu)p[4] * a[5])).F,
            ((((Fpu)p[8] * a[6]) + ((Fpu)p[7] * a[3])) + ((Fpu)p[6] * a[0])).F,
            ((((Fpu)p[6] * a[1]) + ((Fpu)p[8] * a[7])) + ((Fpu)p[7] * a[4])).F,
            ((((Fpu)p[8] * a[8]) + ((Fpu)p[7] * a[5])) + ((Fpu)p[6] * a[2])).F,
        ];
        return true;
    }

    /// <summary>
    /// Tells everything a moved object carries to follow it, <c>ModelObj_UpdateAttachments</c> (<c>igi2 0x56D7C0</c>): each child
    /// that follows a parent does, and a child that is only a holder of others -- a container, a sound generator -- passes it on
    /// to its own.
    /// </summary>
    /// <param name="task">The object that moved, or a holder beneath it.</param>
    public static void UpdateChildren(GameTask task)
    {
        ArgumentNullException.ThrowIfNull(task);
        foreach (GameTask child in task.Children)
        {
            UpdateChild(child);
        }
    }

    /// <summary>Tells one child of an object that moved to follow it, or, a holder, to pass it on (<see cref="UpdateChildren"/>).</summary>
    /// <param name="child">The child.</param>
    public static void UpdateChild(GameTask child)
    {
        ArgumentNullException.ThrowIfNull(child);
        if (child is IIgi2Attached attached)
        {
            attached.UpdateAttachment();
        }
        else
        {
            UpdateChildren(child);
        }
    }

    /// <summary>
    /// Holds everything beneath an object that moves to it as the level placed them, so each follows from then on: what a holder
    /// holds is held to the object above the holder, and what a carried object carries in its turn is held to that.
    /// </summary>
    /// <param name="parent">The object that moves.</param>
    /// <param name="task">The object, or a holder beneath it.</param>
    /// <param name="carriedParent">Told of each carried object that carries others itself, before they are held to it.</param>
    public static void AttachChildren(IAttachParent parent, GameTask task, Action<IAttachParent>? carriedParent = null)
    {
        ArgumentNullException.ThrowIfNull(parent);
        ArgumentNullException.ThrowIfNull(task);
        foreach (GameTask child in task.Children)
        {
            AttachChild(parent, child, carriedParent);
        }
    }

    /// <summary>Holds one child beneath an object that moves to it, or what a holder holds (<see cref="AttachChildren"/>).</summary>
    /// <param name="parent">The object that moves.</param>
    /// <param name="child">The child.</param>
    /// <param name="carriedParent">Told of each carried object that carries others itself, before they are held to it.</param>
    public static void AttachChild(IAttachParent parent, GameTask child, Action<IAttachParent>? carriedParent = null)
    {
        ArgumentNullException.ThrowIfNull(parent);
        ArgumentNullException.ThrowIfNull(child);
        if (child is IIgi2Carried carried)
        {
            if (carried.AttachTo(parent) && child is IAttachParent nested)
            {
                carriedParent?.Invoke(nested);
                AttachChildren(nested, child, carriedParent);
            }
        }
        else if (child is not IIgi2Attached)
        {
            AttachChildren(parent, child, carriedParent);
        }
    }
}
