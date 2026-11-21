using ProjectIGI.Core.Configuration;
using ProjectIGI.Core.Diagnostics;
using ProjectIGI.Core.Graphics;
using ProjectIGI.Core.Numerics;
using ProjectIGI.Engine.Tasks;
using ProjectIGI.Formats.Ai;
using ProjectIGI.Formats.Animation;
using ProjectIGI.Formats.World;
using ProjectIGI.Game.Ai;
using ProjectIGI.Game.Level;
using ProjectIGI.Game.Player;
using ProjectIGI.Game.Weapons;
using ProjectIGI.Game.World;

namespace ProjectIGI.Game.Hosting;

/// <summary>
/// The mission of a title whose level runs itself behind its player: the host's steps around that player's tick, and none of
/// another game's systems.
/// </summary>
public sealed class TitleMission(IMissionHostServices host, ITitleGameplay gameplay) : IHostedMission
{
    private readonly ITitleGameplay _gameplay = gameplay ?? throw new ArgumentNullException(nameof(gameplay));
    private readonly Parts _parts = new(host ?? throw new ArgumentNullException(nameof(host)));

    /// <summary>Gets the title's own gameplay.</summary>
    public ITitleGameplay Gameplay => _gameplay;

    /// <inheritdoc/>
    public IHostedPlayer? Player => null;

    /// <inheritdoc/>
    public bool OwnsLevel => false;

    /// <inheritdoc/>
    public MissionState World => _parts.State;

    /// <inheritdoc/>
    public IMissionTick Tick => _parts;

    /// <inheritdoc/>
    public IMissionSetup Setup => _parts;

    /// <inheritdoc/>
    public IMissionAudio Audio => _parts;

    /// <inheritdoc/>
    public IMissionCries Sounds => _parts;

    /// <inheritdoc/>
    public IMissionImpacts Impacts => _parts;

    /// <inheritdoc/>
    public IReadOnlyList<TitleInputBinding> InputBindings => _gameplay.InputBindings;

    /// <inheritdoc/>
    public ITitlePlayer? CreatePlayer(in TitlePlayerRequest request) => _gameplay.CreatePlayer(request);

    /// <inheritdoc/>
    public void Prefetch()
    {
    }

    /// <inheritdoc/>
    public IPlayerBringUp NewPlayerSetup() => new NoPlayer(_parts.Logger);

    /// <inheritdoc/>
    public void AddMissionSystems(LevelSystems<MissionLevelBuild> systems)
    {
        ArgumentNullException.ThrowIfNull(systems);
        systems.InsertBefore(MissionSystemNames.TestCaptures, new LevelSystem<MissionLevelBuild>(MissionSystemNames.Cutscenes, b =>
        {
            World.LevelRoot = b.LevelRoot;
            IMissionSetupHost setup = _parts.Host;
            b.MissionText = new MissionStringResolver(setup.Resources, new MenuStringTable(setup.Resources));
        }));
    }

    private sealed class Parts(IMissionHostServices host) : IMissionTick, IMissionSetup, IMissionAudio, IMissionCries, IMissionImpacts
    {
        public MissionState State { get; } = new();

        public IMissionHostServices Host => host;

        public IProjectIGILogger Logger => ((IMissionSetupHost)host).Logger;

        public bool HasSoldiers => false;

        public void Run(bool tick)
        {
            if (!tick)
            {
                return;
            }

            State.PlayerTicked = false;
            State.InteractionsTickedByPlayer = false;
            host.StepWeather();
            bool stands = host.TickTitlePlayer();

            bool walking = stands && host.PlayerMode && State.Cutscenes?.IsPlaying != true;
            if (!walking || State.PlayerTicked || State.IsPlayerDead)
            {
                host.StepWorldEffects();
            }

            host.StepScreen();
            host.ApplyTestWrites();
            host.CloseTick();
        }

        public void ResetReports() {}
        public void ResetClimbs() {}
        public void AttachToLevelWalk(GameTask levelRoot) {}
        public AreaPlayer AreaPlayerNow() => default;

        public MissionStringResolver BuildCutscenes(LoadedMission loaded, LevelTask levelRoot, LevelUpdateWalker walker, Func<MissionObjectiveRuntime?> objectives)
        {
            IMissionSetupHost setup = Host;
            return new MissionStringResolver(setup.Resources, new MenuStringTable(setup.Resources));
        }

        public MissionObjectiveRuntime BuildObjectives(LevelTask levelRoot, MissionStringResolver missionText, Func<AreaPlayer> areaPlayer, Action<MissionObjectiveRuntime> made) => null!;

        public void BuildInteractions(LoadedMission loaded, LevelTask levelRoot, ObjectCollisionIndex solids, IReadOnlyList<WorldPlacement>? placements = null) {}

        public WorldTraceCast BuildCameras(LevelTask levelRoot, WorldScene scene, ObjectCollisionIndex solids, TerrainData? terrain) => (in WorldTraceRequest r, out WorldTraceHit h) => { h = default; return false; };

        public Dictionary<int, GraphFile> ReadNavGraphs(LoadedMission loaded, LevelTask levelRoot, string gamePath, IReadOnlyList<WorldPlacement>? placements = null) => [];

        public void AnimateSoldiers(LevelTask levelRoot, WorldScene scene, WorldTraceCast worldTrace, Dictionary<int, GraphFile> graphs, AiDifficulty difficulty, string difficultySource) {}

        public void BuildVehicles(LoadedMission loaded, LevelTask levelRoot, int id, WorldScene scene, ObjectCollisionIndex solids) {}

        public void OnDeviceOpened() {}
        public void ResetForMission() {}
        public void ForgetAmbience() {}
        public void ForgetCameras() {}
        public void ForgetSirens() {}

        public void PlayPlayerImpacts() {}
        public void PlayRicochet(Vector3d position) {}

        public void Reset(int mistFrames) {}
        public void ConnectSoldiers() {}
        public void Tick() {}
        public void SpawnPlayerImpacts() {}
        public void Register(ConsoleSystem console, Func<Camera3D> eye, IProjectIGILogger logger) {}
    }

    private sealed class NoPlayer(IProjectIGILogger logger) : IPlayerBringUp
    {
        public WeaponTypeRegistry Weapons { get; } = new(logger);
        public IHostedPlayer Player => null!;
        public BoneAnimationSet? BodyAnimations => null;

        public void Begin(LoadedMission loaded, LevelTask levelRoot, ObjectCollisionIndex solids, MissionStringResolver missionText) {}
        public void ArmVehicles(LoadedMission loaded, LevelTask levelRoot) {}
        public void Configure() {}
        public void UseViewRig(BoneAnimationSet animations) {}
        public bool CarryDeclaredLoadout(LevelTask levelRoot, out bool carried) { carried = false; return false; }
        public void ConnectSoldiers(Action<Vector3d> deflected) {}
        public bool Stand(LevelTask levelRoot, IGroundHeightField? ground, ObjectCollisionIndex solids, Vector3d? opening, float openingYaw, out PlayerSpawnPoint spawn) { spawn = default; return false; }
    }
}
