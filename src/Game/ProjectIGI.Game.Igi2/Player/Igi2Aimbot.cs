using ProjectIGI.Core.Numerics;
using ProjectIGI.Game.Igi2.Collision;
using ProjectIGI.Game.Igi2.Humans;
using ProjectIGI.Game.Igi2.Soldiers;
using ProjectIGI.Game.Physics;
using ProjectIGI.Game.Player;
using ProjectIGI.Game.World;

namespace ProjectIGI.Game.Igi2.Player;

/// <summary>
/// The aimbot cheat: steers the player's view onto a visible enemy, as an assist rather than a
/// snap. IGI 2 has no aim-assist of its own — code search for AimAssist, Aimbot, AutoAim and
/// AimLock finds nothing in the port — so this is built new, mirroring IGI 1's aim-lock envelope
/// (a 27° cone out to 60 m, aiming at the guard's chest, about 0.95 m above its feet) as the
/// defaults. It only runs while the cheat is on; with it off the input reaches the human untouched.
/// </summary>
/// <remarks>
/// <para>
/// The steering goes through the same channel block the player's own look fills, so the retail
/// view math — the turn-speed cap, the pitch clamp, the mouse filtering, the field of view — all
/// still applies, and the player can always fight the lock by looking away: the aimbot's rate is
/// capped, the player's input is not.
/// </para>
/// <para>
/// The view it reads is last tick's placed view (<see cref="Igi2HumanPlayer.View"/>), the same one
/// the frame draws, so the error it steers on is the error the player sees. The aim point is the
/// soldier's detection point — the chest is the middle of the body, the head is the eyes — the
/// same points the AI's own visibility uses, so a target the aimbot picks is one the game already
/// knows how to see.
/// </para>
/// </remarks>
public sealed class Igi2Aimbot
{
    /// <summary>The fastest the aimbot turns the view, in radians per tick, at full strength.</summary>
    /// <remarks>
    /// IGI 1's aim-lock tops out at 0.228 rad/s, about 0.0076 rad/tick at 30 ticks a second; a cheat
    /// is allowed to be stronger than an assist, so full strength is 0.25 rad/tick (7.5 rad/s), and
    /// the default strength of 0.5 is 0.125 rad/tick (3.75 rad/s) — still a smooth pull, not a snap.
    /// </remarks>
    private const float FullRateRadiansPerTick = 0.25f;

    /// <summary>How hard the aimbot pulls toward the target, as a share of its full rate.</summary>
    private const float SteeringGain = 0.5f;

    /// <summary>How many of the best candidates the line of sight is checked for, best first.</summary>
    private const int CandidatesChecked = 4;

    /// <summary>
    /// How close to the target a trace may stop and still count as a clear line: half a metre, in
    /// world units. The aim point sits inside the soldier, so the trace meets the soldier's own
    /// collider a little short of the point; anything nearer than that is a wall in the way.
    /// </summary>
    private const double LineOfSightMarginUnits = 2048.0;

    /// <summary>The one line the aimbot traces, reused across ticks, as the gunshot reuses its own.</summary>
    private readonly WorldLineTrace _trace = new(1);

    /// <summary>
    /// Steers the view toward the best visible enemy, by adding to the look channels of the frame
    /// the human is about to read. A no-op unless the cheat is on and a target is in front of the
    /// player.
    /// </summary>
    /// <param name="human">The player, whose placed view is read.</param>
    /// <param name="soldiers">The level's soldiers, or <see langword="null"/> when there is no level.</param>
    /// <param name="collisionWorld">The world's traces, for the line of sight.</param>
    /// <param name="cheats">The cheats in force, whose aimbot values steer this.</param>
    /// <param name="frame">The channel frame the human reads this tick; the look slots are added to.</param>
    public void Steer(
        Igi2HumanPlayer human,
        Igi2Soldiers? soldiers,
        Igi2CollisionWorld collisionWorld,
        PlayerCheatOptions cheats,
        Span<float> frame)
    {
        if (!cheats.Aimbot || human.IsDead || soldiers is null)
        {
            return;
        }

        Vector3d eyes = human.View.Position;
        Matrix3f orientation = human.View.Orientation;

        // The view's forward: the second column of the orientation (M12, M22, M32), the direction
        // the camera looks, as UpdateView builds it from IdealGamma and IdealPitch.
        Vector3f forward = new(orientation.M12, orientation.M22, orientation.M32);
        float forwardLength = forward.Length;
        if (forwardLength <= 0f)
        {
            return;
        }

        forward /= forwardLength;

        float maxDistanceUnits = cheats.AimbotMaxDistance * (float)WorldScene.UnitsPerMetre;
        float coneCos = MathF.Cos(cheats.AimbotCone * (MathF.PI / 180f));

        // The best few candidates by score, best first: the line of sight is only traced for these,
        // so a blocked best target falls through to the next visible one instead of switching the
        // aimbot off for the tick.
        Span<Candidate> candidates = stackalloc Candidate[CandidatesChecked];
        int candidateCount = 0;
        foreach (Igi2HumanSoldier soldier in soldiers.Bodies)
        {
            if (!soldier.IsActive || soldier.IsDead || soldier.Team == human.Team)
            {
                continue;
            }

            Vector3d aim = cheats.AimbotAimPart == AimbotAimPartKind.Head
                ? soldier.DetectionInfo().Head
                : soldier.DetectionInfo().Middle;
            Vector3d toTarget = aim - eyes;
            double distance = toTarget.Length;
            if (distance <= 0.0 || distance > maxDistanceUnits)
            {
                continue;
            }

            Vector3f direction = toTarget.ToVector3f() / (float)distance;
            float dot = (forward.X * direction.X) + (forward.Y * direction.Y) + (forward.Z * direction.Z);
            if (dot < coneCos)
            {
                continue;
            }

            // Closest to the crosshair scores by angle; nearest scores by distance.
            double score = cheats.AimbotTarget == AimbotTargetKind.ClosestToCrosshair
                ? Math.Acos(Math.Clamp(dot, -1f, 1f))
                : distance;
            InsertCandidate(candidates, ref candidateCount, new Candidate(soldier, aim, score, distance));
        }

        for (int i = 0; i < candidateCount; i++)
        {
            Candidate candidate = candidates[i];
            if (!HasLineOfSight(collisionWorld, human, eyes, candidate.Aim, candidate.Distance))
            {
                continue;
            }

            SteerToward(human, forward, eyes, candidate.Aim, cheats, frame);
            return;
        }
    }

    /// <summary>Whether the line from the eyes to the aim point meets nothing short of the target.</summary>
    /// <remarks>
    /// The trace spares the player's own body — the gunshot's trace does the same for its shooter —
    /// because the line starts at the player's eyes, on the player's own head, and the player's
    /// collider is in the world. Without the spare the player's own head would stop every line at
    /// the face. The trace is the world's own <c>TraceLines</c>, not <c>Cast</c>, because
    /// <c>Cast</c> builds its trace with no spare.
    /// </remarks>
    private bool HasLineOfSight(Igi2CollisionWorld collisionWorld, Igi2HumanPlayer human, Vector3d eyes, Vector3d aim, double distance)
    {
        _trace.Starts[0] = eyes;
        _trace.Ends[0] = aim;
        _trace.Includes = owner => !ReferenceEquals(owner, human);
        collisionWorld.TraceLines(_trace, Igi2CollisionWorld.EveryTypeGroup | Igi2CollisionWorld.TerrainGroup);
        WorldIntersection met = _trace.Intersections[0];
        if (!met.IsHit)
        {
            return true;
        }

        // A hit at the target is the soldier itself: the aim point sits inside it, so the trace
        // meets its collider a little short of the point.
        return met.Distance >= distance - LineOfSightMarginUnits;
    }

    /// <summary>Turns the view toward one aim point, at the aimbot's rate, through the look channels.</summary>
    /// <param name="human">The player, whose field of view scales the look channels.</param>
    /// <param name="forward">The view's forward, unit length.</param>
    /// <param name="eyes">Where the view looks from.</param>
    /// <param name="aim">Where on the target to aim.</param>
    /// <param name="cheats">The cheats in force, whose aimbot strength steers this.</param>
    /// <param name="frame">The channel frame the human reads this tick; the look slots are added to.</param>
    private static void SteerToward(
        Igi2HumanPlayer human,
        Vector3f forward,
        Vector3d eyes,
        Vector3d aim,
        PlayerCheatOptions cheats,
        Span<float> frame)
    {
        Vector3d toTarget = aim - eyes;
        double distance = toTarget.Length;
        if (distance <= 0.0)
        {
            return;
        }

        Vector3f direction = toTarget.ToVector3f() / (float)distance;
        float maxRate = cheats.AimbotStrength * FullRateRadiansPerTick;
        float fieldOfView = human.View.FieldOfView;
        if (fieldOfView <= 0f)
        {
            return;
        }

        // The look channels are in units of PI * FieldOfView per radian of turn (UpdateBody turns
        // by -(LookX * PI) * FieldOfView, UpdateView pitches by PI * LookY * FieldOfView), so a
        // rate in radians per tick is divided by PI * FieldOfView to reach the channel. That keeps
        // the aimbot's rate absolute — a scope's narrow field of view does not make it turn faster.
        float lookScale = 1f / (MathF.PI * fieldOfView);

        // Yaw: the signed horizontal angle from the view to the target, positive when the target
        // sits to the left. A leftward turn raises IdealGamma, and UpdateBody turns by
        // -(LookX * PI) * FieldOfView, so a leftward turn needs a negative LookX.
        float forwardHorizontal = MathF.Sqrt((forward.X * forward.X) + (forward.Y * forward.Y));
        float targetHorizontal = MathF.Sqrt((direction.X * direction.X) + (direction.Y * direction.Y));
        if (forwardHorizontal > 1e-4f && targetHorizontal > 1e-4f)
        {
            float fx = forward.X / forwardHorizontal;
            float fy = forward.Y / forwardHorizontal;
            float dx = direction.X / targetHorizontal;
            float dy = direction.Y / targetHorizontal;
            float yawError = MathF.Atan2((fx * dy) - (fy * dx), (fx * dx) + (fy * dy));
            float yawRate = Math.Clamp(yawError * SteeringGain, -maxRate, maxRate);
            frame[(int)Igi2HumanChannel.LookX] += -yawRate * lookScale;
        }

        // Pitch: the elevation of the target above the view, positive when the target is higher.
        // UpdateView pitches by PI * LookY * FieldOfView, up positive, so an upward turn needs a
        // positive LookY.
        float pitchError = MathF.Asin(Math.Clamp(direction.Z, -1f, 1f)) - MathF.Asin(Math.Clamp(forward.Z, -1f, 1f));
        float pitchRate = Math.Clamp(pitchError * SteeringGain, -maxRate, maxRate);
        frame[(int)Igi2HumanChannel.LookY] += pitchRate * lookScale;
    }

    /// <summary>Keeps the best few candidates in score order, worst dropped when full.</summary>
    private static void InsertCandidate(Span<Candidate> candidates, ref int count, Candidate candidate)
    {
        int at = count;
        while (at > 0 && candidates[at - 1].Score > candidate.Score)
        {
            at--;
        }

        if (at >= candidates.Length)
        {
            return;
        }

        for (int i = Math.Min(count, candidates.Length - 1); i > at; i--)
        {
            candidates[i] = candidates[i - 1];
        }

        candidates[at] = candidate;
        if (count < candidates.Length)
        {
            count++;
        }
    }

    /// <summary>One enemy the aimbot may steer onto, with its aim point and its score.</summary>
    /// <param name="Soldier">The enemy.</param>
    /// <param name="Aim">Where on it to aim.</param>
    /// <param name="Score">Its score: the angle to it, or its distance, lower is better.</param>
    /// <param name="Distance">How far away it is, in world units.</param>
    private readonly record struct Candidate(Igi2HumanSoldier Soldier, Vector3d Aim, double Score, double Distance);
}
