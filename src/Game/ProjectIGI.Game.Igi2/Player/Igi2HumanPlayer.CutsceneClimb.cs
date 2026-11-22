using ProjectIGI.Game.Igi2.Humans;
using ProjectIGI.Game.Igi2.Interaction;

namespace ProjectIGI.Game.Igi2.Player;

/// <content>Climbing a ladder during a cutscene, without input: the cutscene's ladder climb.</content>
public sealed partial class Igi2HumanPlayer
{
    /// <summary>
    /// Gets or sets whether a cutscene is running, as the title player left it this tick: while set, the player climbs a ladder
    /// it stands at the foot of without being told to.
    /// </summary>
    public bool IsCutsceneRunning { get; set; }

    /// <summary>Whether a cutscene climb is under way, started by <see cref="RunCutsceneClimb"/>.</summary>
    private bool _cutsceneClimbActive;

    /// <summary>
    /// Climbs a ladder during a cutscene: while a cutscene runs and the view has found a ladder, the ladder is activated as
    /// though the player had found it (<see cref="ScriptActivate"/>), and forward is held until the climb ends at the top. The
    /// climb itself is the proven ladder states, so getting off at the top is theirs, and a fresh activate press slides down as
    /// in play; when the cutscene ends, the forward is dropped and the climb waits on the ladder for the player's own forward.
    /// </summary>
    /// <remarks>
    /// Run after the activate update, which has found this tick's target, and before the locomotion tick, which packs the signal
    /// from the channels: the forward held here is the one the climb steps on. Forward is held only from the tick after the
    /// activation, so the attach tick still stands and never steps into a walk first.
    /// </remarks>
    private void RunCutsceneClimb()
    {
        if (!IsCutsceneRunning)
        {
            _cutsceneClimbActive = false;
            return;
        }

        if (_cutsceneClimbActive)
        {
            if (IsClimbLadder || IsInitClimbLadder)
            {
                Channels[Igi2HumanChannel.MoveForwards] = 1f;
            }
            else
            {
                // Off the ladder: the top got it off, or something else ended the climb.
                _cutsceneClimbActive = false;
            }

            return;
        }

        if (IsActivating || IsClimbLadder || IsInitClimbLadder)
        {
            return;
        }

        // At a ladder's foot, facing it, during a cutscene: climb it without input.
        if (EvaluateTarget is IIgi2Ladder ladder)
        {
            ScriptActivate(ladder);
            if (IsInitClimbLadder)
            {
                _cutsceneClimbActive = true;
            }
        }
    }
}
