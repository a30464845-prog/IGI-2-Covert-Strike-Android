using ProjectIGI.Core.Numerics;

namespace ProjectIGI.Game.World;

/// <summary>Says which of a title's panes of glass have left the world, so they are left out of the frame.</summary>
/// <remarks>
/// The sibling of <see cref="IPlacementPresence"/> for a pane that broke rather than a placement whose task left the
/// world: the title owns the glass its buildings hang, and the renderer asks which panes are gone.
/// </remarks>
public interface IPlacementGlass
{
    /// <summary>Gets a value indicating whether a pane drawn at a place, by the task that placed it, has left the world.</summary>
    /// <param name="levelId">The placing task's level id.</param>
    /// <param name="positionUnits">Where the pane is drawn, in engine units.</param>
    /// <returns><see langword="true"/> for a pane that is gone.</returns>
    bool IsGone(int levelId, Vector3d positionUnits);
}
