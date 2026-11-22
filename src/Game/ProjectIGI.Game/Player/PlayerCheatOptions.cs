namespace ProjectIGI.Game.Player;

/// <summary>Where on a target the aimbot aims.</summary>
public enum AimbotAimPartKind
{
    /// <summary>The middle of the body, halfway between the head and the feet.</summary>
    Chest,

    /// <summary>The head, at the eyes.</summary>
    Head,
}

/// <summary>Which visible enemy the aimbot picks.</summary>
public enum AimbotTargetKind
{
    /// <summary>The enemy whose aim point sits closest to the crosshair.</summary>
    ClosestToCrosshair,

    /// <summary>The enemy nearest to the player.</summary>
    Nearest,
}

/// <summary>The cheats in force for one player, as one immutable value.</summary>
/// <param name="SpeedMultiplier">Scales root-motion movement, air control and horizontal jump carry.</param>
/// <param name="JumpMultiplier">Scales the vertical jump launch speed.</param>
/// <param name="HealthMultiplier">Scales the maximum health humanplayer.qvm's argument 7 sets.</param>
/// <param name="InfiniteHealth">Whether hits, falls and fences leave the player's health untouched.</param>
/// <param name="InfiniteAmmo">Whether firing takes nothing: magazines stay full and reserves untouched.</param>
/// <param name="AllWeapons">Whether the player carries every weapon the mission loaded.</param>
/// <param name="UnlockAllLevels">Whether every campaign mission may be played.</param>
/// <param name="NoRecoil">Whether fired rounds leave the view where it was.</param>
/// <param name="NoReload">Whether the magazine refills from the reserve without a reload, until the reserve runs out.</param>
/// <param name="Aimbot">Whether the view steers onto a visible enemy in front of the player.</param>
/// <param name="AimbotStrength">How fast the aimbot steers, as a share of its full rate.</param>
/// <param name="AimbotMaxDistance">How far away the aimbot looks for a target, in metres.</param>
/// <param name="AimbotCone">How wide the aimbot's lock cone is, in degrees from the crosshair.</param>
/// <param name="AimbotAimPart">Where on the target the aimbot aims.</param>
/// <param name="AimbotTarget">Which visible enemy the aimbot picks.</param>
public readonly record struct PlayerCheatOptions(
    float SpeedMultiplier,
    float JumpMultiplier,
    float HealthMultiplier,
    bool InfiniteHealth,
    bool InfiniteAmmo,
    bool AllWeapons,
    bool UnlockAllLevels,
    bool NoRecoil,
    bool NoReload,
    bool Aimbot,
    float AimbotStrength,
    float AimbotMaxDistance,
    float AimbotCone,
    AimbotAimPartKind AimbotAimPart,
    AimbotTargetKind AimbotTarget)
{
    /// <summary>Gets the set with every cheat off: the unmodified game.</summary>
    public static PlayerCheatOptions Retail { get; } = new(
        SpeedMultiplier: 1f,
        JumpMultiplier: 1f,
        HealthMultiplier: 1f,
        InfiniteHealth: false,
        InfiniteAmmo: false,
        AllWeapons: false,
        UnlockAllLevels: false,
        NoRecoil: false,
        NoReload: false,
        Aimbot: false,
        AimbotStrength: 0.5f,
        AimbotMaxDistance: 60f,
        AimbotCone: 27f,
        AimbotAimPart: AimbotAimPartKind.Chest,
        AimbotTarget: AimbotTargetKind.ClosestToCrosshair);

    /// <summary>Gets the cheats the variables ask for, or <see cref="Retail"/> while either gate is shut.</summary>
    public static PlayerCheatOptions Current
    {
        get
        {
            bool anyCheat = PlayerCheatCVars.InfiniteHealth.Value
                || PlayerCheatCVars.InfiniteAmmo.Value
                || PlayerCheatCVars.AllWeapons.Value
                || PlayerCheatCVars.UnlockAllLevels.Value
                || PlayerCheatCVars.NoRecoil.Value
                || PlayerCheatCVars.NoReload.Value
                || PlayerCheatCVars.Aimbot.Value
                || PlayerCheatCVars.Speed.Value != 1f
                || PlayerCheatCVars.Jump.Value != 1f
                || PlayerCheatCVars.HealthScale.Value != 1f;

            bool dev = PlayerCheatCVars.DeveloperMode.Value || anyCheat;
            bool enabled = PlayerCheatCVars.CheatsEnabled.Value || anyCheat;

            return Activate(
                new PlayerCheatOptions(
                    PlayerCheatCVars.Speed.Value,
                    PlayerCheatCVars.Jump.Value,
                    PlayerCheatCVars.HealthScale.Value,
                    PlayerCheatCVars.InfiniteHealth.Value,
                    PlayerCheatCVars.InfiniteAmmo.Value,
                    PlayerCheatCVars.AllWeapons.Value,
                    PlayerCheatCVars.UnlockAllLevels.Value,
                    PlayerCheatCVars.NoRecoil.Value,
                    PlayerCheatCVars.NoReload.Value,
                    PlayerCheatCVars.Aimbot.Value,
                    PlayerCheatCVars.AimbotStrength.Value,
                    PlayerCheatCVars.AimbotMaxDistance.Value,
                    PlayerCheatCVars.AimbotCone.Value,
                    PlayerCheatCVars.AimbotAimPart.Value,
                    PlayerCheatCVars.AimbotTarget.Value),
                dev,
                enabled);
        }
    }

    /// <summary>Applies the two session gates to a configured set.</summary>
    /// <param name="configured">The cheats the variables ask for.</param>
    /// <param name="developerMode">Whether developer mode is on.</param>
    /// <param name="cheatsEnabled">Whether cheats are enabled.</param>
    /// <returns><paramref name="configured"/> when both gates are open; otherwise <see cref="Retail"/>.</returns>
    public static PlayerCheatOptions Activate(PlayerCheatOptions configured, bool developerMode, bool cheatsEnabled) =>
        developerMode && cheatsEnabled ? configured : Retail;
}
