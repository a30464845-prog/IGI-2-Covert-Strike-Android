using ProjectIGI.Core.Graphics;
using ProjectIGI.Core.Numerics;
using ProjectIGI.Game.Igi2.Player;
using ProjectIGI.Game.Weapons.Ballistics;
using ProjectIGI.Game.World;
using ProjectIGI.Presentation;

namespace ProjectIGI.Presentation.Igi2.World;

/// <summary>What I.G.I. 2's player has put in the world: its marks.</summary>
/// <remarks>
/// The grenades, rockets and launcher rounds are <b>not</b> drawn here: they already reach the frame
/// as world models through <c>Igi2TitlePlayer.Gather</c>, and the held weapon is never drawn in
/// third person. The three inert members below preserve exactly that -- they exist only because the
/// host asks the world view for them once one exists.
/// </remarks>
/// <param name="gameplay">The sequel's mission.</param>
internal sealed class Igi2WorldView(Igi2Gameplay gameplay) : IMissionWorldView
{
    /// <inheritdoc/>
    public BallisticSimulation? Ballistics => null;

    /// <inheritdoc/>
    public bool TryHeldWeapon(out int shotSequence)
    {
        shotSequence = 0;
        return false;
    }

    /// <inheritdoc/>
    public void DrawProjectiles(IGrenadePresenter? grenades, IMissilePresenter? missiles, in Camera3D eye, in Matrix4f projection, float tickBlend)
    {
    }

    /// <inheritdoc/>
    public void DrawMarks(IBulletMarkPresenter marks, in Camera3D eye, in Matrix4f projection, PlacementPose? poses)
    {
        ArgumentNullException.ThrowIfNull(marks);
        marks.Draw(gameplay.Marks, eye, projection, poses);
    }
}
