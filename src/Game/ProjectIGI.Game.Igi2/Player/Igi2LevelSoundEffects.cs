using ProjectIGI.Core.Numerics;
using ProjectIGI.Game.Igi2.Audio;
using ProjectIGI.Game.Igi2.Collision;
using ProjectIGI.Game.Igi2.Weapons;
using ProjectIGI.Game.Igi2.World;
using ProjectIGI.Game.Physics;
using ProjectIGI.Game.Weapons;
using ProjectIGI.Game.World;
using ProjectIGI.Game.World.Particles;

namespace ProjectIGI.Game.Igi2.Player;

/// <summary>What a bullet's flight sounds in the level; what it shows arrives with its presentation.</summary>
/// <param name="sounds">The level's sounds.</param>
/// <param name="ai">The session's AI, which hears the events, or <see langword="null"/>.</param>
/// <param name="marks">Where a bullet's holes go, or <see langword="null"/> when nothing records them.</param>
internal sealed class Igi2LevelImpactEffects(Igi2Sounds sounds, Ai.Runtime.Igi2AiWorld? ai = null, BulletMarks? marks = null) : IIgi2GunShotEffects
{
    /// <inheritdoc/>
    public bool NewSound(string sound, Vector3d position) => sounds.New(sound, position) is not null;

    /// <inheritdoc/>
    public void SendAiEvent(in Igi2WeaponAiEvent aiEvent) =>
        ai?.SendEvent(new Ai.Igi2AiEvent(aiEvent.Event, aiEvent.Team, aiEvent.Flags, aiEvent.Radius, aiEvent.Position, aiEvent.Direction, aiEvent.Originator, aiEvent.Reference));

    /// <inheritdoc/>
    public void Tracer(in Igi2Tracer tracer)
    {
    }

    /// <summary>Gets or sets where an impact's chips fly, an explosion of no damage, or <see langword="null"/> for none.</summary>
    public Igi2ExplosionWorld? Explosions { get; set; }

    /// <summary>The impact puff's sprite: IGI 1's <c>PuffSprite</c>, the grey dust its puffs rise as.</summary>
    public const string SmokeSprite = "concrete1.spr";

    /// <summary>Gets or sets the level's particle engine, whose systems the title-particle drawer shows.</summary>
    public Igi2Particles? Particles { get; set; }

    /// <inheritdoc/>
    /// <remarks>
    /// <c>GunShotEffect_CreateEffectHandler</c>'s <c>Explosion0_NewEx</c>: once, at once, no damage over two metres, its chips the
    /// effect's model thrown in a twelfth of a turn about the shot at 340 to 680 a tick, no sound, no AI event; the angles already
    /// drawn. It runs on the ticks after as any explosion does.
    /// </remarks>
    public void Fragments(in Igi2ImpactFragments fragments)
    {
        Explosions?.Start(
            new Igi2ExplosionRequest(
                fragments.Position,
                1,
                0,
                0f,
                2048f,
                0f,
                0f,
                fragments.Fragments,
                0,
                null,
                fragments.Model,
                string.Empty,
                -1,
                0x402,
                49152f,
                fragments.Direction,
                0.5235987901687622f,
                340f,
                680f,
                null,
                null,
                Igi2ExplosionFalloff.Linear),
            fragments.Spin);
    }

    /// <inheritdoc/>
    public void WaterSplash(in Igi2WaterSplash splash)
    {
        // Water_GunShotEffect: the splash and, maybe, a ripple, on the body the bullet struck.
        if (splash.Intersection.HitObject is World.Igi2WaterBody water)
        {
            water.Module.BulletEffect(water, splash.Intersection.Position, splash.Penetration, splashTexture: null);
        }
    }

    /// <inheritdoc/>
    public void BulletHole(in Igi2BulletHoleMark hole)
    {
        if (marks is null || !Igi2BulletHoles.Takes(hole.Struck))
        {
            return;
        }

        // The same five millimetres IGI 1 lifts a mark off its surface
        // (BulletMarks.Lift / GunShotBallistics.PenetrationStepOffUnits), so the quad does not
        // z-fight the wall it sits on.
        Vector3f n = hole.Intersection.Normal.NormalizedOr(Vector3f.UnitZ, 1e-6f);
        Vector3d at = new(
            hole.Intersection.Position.X + (n.X * GunShotBallistics.PenetrationStepOffUnits),
            hole.Intersection.Position.Y + (n.Y * GunShotBallistics.PenetrationStepOffUnits),
            hole.Intersection.Position.Z + (n.Z * GunShotBallistics.PenetrationStepOffUnits));

        // hole.Size is vBulletHoleSize in world units, passed through as the half-width exactly as
        // IGI 1 passes its material's SizeInUnits: 0x47D920 lays the decal's corners at +-size.
        // No placement is resolved yet (v1): the mark stays where it was made rather than riding a
        // moving door, and there is no corner probe, so one may overhang an edge.
        marks.AddMark(at, n, hole.Texture, hole.Size, surface: hole.Struck, placement: null);
    }

    /// <inheritdoc/>
    public void Smoke(in Igi2ImpactSmoke smoke)
    {
        if (Particles is not { } particles)
        {
            return;
        }

        // IGI 1's GunShotImpactEffects.PuffLook / ImpactEffectRuntime.Puff: one two-particle
        // system per impact, grey, growing 0.08888889/tick, holding 15 ticks, fading over 30.
        // Size is the weapon's Smoke Particle Size, already in world units (Igi2GunShotEffect).
        Particle2DSystem puff = particles.New(
            SmokeSprite, animated: false, frames: 1,
            acceleration: Vector3f.Zero,
            color: new Vector3f(127f, 127f, 127f),
            width: smoke.Size, height: smoke.Size, range: 409600f,
            transparency: Particle2DFlags.Filtered | Particle2DFlags.FadesByOpacity,
            animationDelta: 0, sizeDelta: 0.08888889f, shininess: 0f,
            maxParticles: 2, onCollision: null);
        puff.AddParticle(smoke.First, new Vector3f(0f, 0f, smoke.FirstRise), smoke.Intensity, smoke.FirstSpin, 0f, 1f, 15, 30);
        puff.AddParticle(smoke.Second, new Vector3f(0f, 0f, smoke.SecondRise), smoke.Intensity, smoke.SecondSpin, 0f, 1f, 15, 30);
    }
}

/// <summary>What an explosion sounds in the level.</summary>
/// <param name="sounds">The level's sounds.</param>
/// <param name="ai">The session's AI, which hears the events, or <see langword="null"/>.</param>
internal sealed class Igi2LevelExplosionEffects(Igi2Sounds sounds, Ai.Runtime.Igi2AiWorld? ai = null) : IIgi2ExplosionEffects
{
    /// <inheritdoc/>
    public void BurnMark(WorldIntersection ground, float radius)
    {
    }

    /// <inheritdoc/>
    public void Sound(string sound, Vector3d position) => sounds.New(sound, position);

    /// <inheritdoc/>
    public void AiEvent(int aiEvent, int flags, Vector3d position, float range, int team = 1) =>
        ai?.SendEvent(new Ai.Igi2AiEvent(aiEvent, team, flags, range, position, default, null));
}

/// <summary>
/// What firing sounds in the level: the weapon's sound slots and its sound sequence, every sound hanging off the holder's
/// view as a player's do (<c>Weapon_PlaySound</c>, <c>igi2 0x51F290</c>, makes them under <c>Human + 0x540</c>).
/// </summary>
/// <param name="sounds">The level's sounds.</param>
/// <param name="view">Where the holder's view is.</param>
/// <param name="ai">The session's AI, which hears the events, or <see langword="null"/>.</param>
/// <param name="casings">Throws a shot's casing from the holder's weapon object, or <see langword="null"/> for none.</param>
internal sealed class Igi2LevelWeaponEffects(
    Igi2Sounds sounds,
    Func<Vector3d> view,
    Ai.Runtime.Igi2AiWorld? ai = null,
    Action<Igi2CasingEjection>? casings = null) : IIgi2WeaponEffects
{
    /// <summary>The most sounds a sequence holds, <c>Weapon_s + 0x28C</c> against ten.</summary>
    public const int SequenceLength = 10;

    /// <summary>The longest name a sequence takes, one short of its 32-byte field.</summary>
    public const int SequenceNameLength = 31;

    private readonly Dictionary<int, Igi2Sound> _slots = [];
    private readonly List<SequencedSound> _sequence = [];

    /// <inheritdoc/>
    public void CreateProjectile(in Igi2ProjectileLaunch launch)
    {
    }

    /// <inheritdoc/>
    public void SendAiEvent(in Igi2WeaponAiEvent aiEvent) =>
        ai?.SendEvent(new Ai.Igi2AiEvent(aiEvent.Event, aiEvent.Team, aiEvent.Flags, aiEvent.Radius, aiEvent.Position, aiEvent.Direction, aiEvent.Originator, aiEvent.Reference));

    /// <inheritdoc/>
    public void MuzzleFlash(int weaponObject, string? sprite, float size)
    {
    }

    /// <inheritdoc/>
    public void EjectCasing(in Igi2CasingEjection casing) => casings?.Invoke(casing);

    /// <inheritdoc/>
    /// <remarks>
    /// The slot's sound is deleted, then the new one made in its place. Retail is passed whether it loops and never reads
    /// it: a sound loops as its definition says.
    /// </remarks>
    public void PlaySound(int slot, string sound, bool looped)
    {
        if (_slots.Remove(slot, out Igi2Sound? playing))
        {
            playing.Delete();
        }

        if (sounds.New(sound, view(), view) is { } made)
        {
            _slots[slot] = made;
        }
    }

    /// <inheritdoc/>
    public void StopAllSounds()
    {
        foreach (Igi2Sound playing in _slots.Values)
        {
            playing.Delete();
        }

        _slots.Clear();
        ClearSoundSequence();
    }

    /// <inheritdoc/>
    /// <remarks><c>Weapon_DeleteFirstSoundInSoundSequence</c> (<c>igi2 0x51F610</c>) until none is left: each one's sound is deleted.</remarks>
    public void ClearSoundSequence()
    {
        while (_sequence.Count > 0)
        {
            DeleteFirst();
        }
    }

    /// <inheritdoc/>
    /// <remarks>A name of 32 characters or more, or an eleventh sound, is not taken.</remarks>
    public void AddSoundToSequence(string sound, float timeToPlay)
    {
        ArgumentNullException.ThrowIfNull(sound);
        if (sound.Length <= SequenceNameLength && _sequence.Count < SequenceLength)
        {
            _sequence.Add(new SequencedSound(sound, timeToPlay));
        }
    }

    /// <inheritdoc/>
    /// <remarks>
    /// The first sound started is dropped once it has ended, or, with a time to play, once it has played longer; the
    /// next is then started, made to play once. One nothing defines is tried again each tick.
    /// </remarks>
    public void MaintainSoundSequence()
    {
        while (_sequence.Count > 0 && _sequence[0].Sound is { } first)
        {
            float time = _sequence[0].TimeToPlay;
            if (first.IsAlive && !(time > 0f && first.Seconds > time))
            {
                return;
            }

            DeleteFirst();
        }

        if (_sequence.Count > 0)
        {
            _sequence[0] = _sequence[0] with { Sound = sounds.New(_sequence[0].Name, view(), view, looping: false) };
        }
    }

    /// <inheritdoc/>
    public void ShowOverlay(Igi2ZoomTask zoom) => Overlay = zoom;

    /// <inheritdoc/>
    public void RemoveOverlay() => Overlay = null;

    /// <summary>Gets the zoom whose overlay is up, the weapon's overlay task (<c>Weapon+0xA4</c>), or <see langword="null"/>.</summary>
    public Igi2ZoomTask? Overlay { get; private set; }

    /// <inheritdoc/>
    public void PlayViewSound(string sound) => sounds.New(sound, view(), view);

    private void DeleteFirst()
    {
        _sequence[0].Sound?.Delete();
        _sequence.RemoveAt(0);
    }

    /// <summary>One of the sequence's 44-byte entries: its sound once started, its name and its time to play.</summary>
    private readonly record struct SequencedSound(string Name, float TimeToPlay, Igi2Sound? Sound = null);
}
