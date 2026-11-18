using ProjectIGI.Core.Configuration;

namespace ProjectIGI.Rendering;

/// <summary>The retail graphics options I.G.I. 2's menu keeps that no renderer variable names, mirrored so they survive a relaunch.</summary>
/// <remarks>
/// <para>
/// The retail menu writes its graphics screens into the <c>GfxOptions_*</c> record and the active
/// profile, and neither is ever written to disk: the record is re-read from the retail
/// <c>config.qvm</c> on every launch, and the profile's save hook is never assigned. The options
/// <see cref="ProjectIGI.Presentation.Igi2.Menus.Igi2GraphicsApplier"/> already maps to renderer
/// variables survive through <c>settings.cfg</c>; the rest — the model-detail slider, the forest,
/// flare and shadow toggles, the water quality, the gamma and the crosshair — were forgotten on
/// every restart, and the screens opened showing the retail defaults however the player had left
/// them. These variables are the mirror that remembers them: the applier writes the record and
/// the profile into them when the menu's OK applies, and seeds the record and the profile back
/// out of them when the menus start.
/// </para>
/// <para>
/// Mirrors, not live stores: nothing in the renderer reads these. The options with live readers
/// (model detail, high-quality forests, lens flares, the crosshair) are read out of the record
/// and the profile, which the seeding restores; the options with no reader anywhere keep being
/// remembered on the screen and doing nothing visible, exactly as the applier's remarks say.
/// Their defaults are the record's and the profile's own defaults, so seeding on a first run —
/// when no settings file exists — leaves the retail values exactly as the file gave them.
/// </para>
/// </remarks>
[CVarContainer]
public static class Igi2RetailCVars
{
    /// <summary>The retail Model Detail slider, nought to one: how far away soldiers stop being drawn.</summary>
    public static readonly NumericCVar<float> ModelDetail = CVar.Float(
        "r_igi2_model_detail",
        1f,
        0f,
        1f,
        CVarOptions.Archive,
        "I.G.I. 2 retail Model Detail: 1 draws soldiers at full distance, lower culls them nearer.");

    /// <summary>Whether the retail Stencil Shadows toggle is on.</summary>
    public static readonly BoolCVar StencilShadows = CVar.Bool(
        "r_igi2_stencil_shadows",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail Stencil Shadows toggle. Remembered; the deferred path it needs never runs on Android.");

    /// <summary>Whether the retail Texture Compression toggle is on.</summary>
    public static readonly BoolCVar TextureCompression = CVar.Bool(
        "r_igi2_texture_compression",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail Texture Compression toggle. Remembered; nothing reads it.");

    /// <summary>Whether the retail High Quality Forests toggle is on.</summary>
    public static readonly BoolCVar HighQualityForests = CVar.Bool(
        "r_igi2_hq_forests",
        true,
        CVarOptions.Archive,
        "I.G.I. 2 retail High Quality Forests toggle.");

    /// <summary>Whether the retail Wind On Forests toggle is on.</summary>
    public static readonly BoolCVar WindOnForests = CVar.Bool(
        "r_igi2_forest_wind",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail Wind On Forests toggle. Remembered; nothing reads it.");

    /// <summary>Whether the retail Lens Flares toggle is on.</summary>
    public static readonly BoolCVar LensFlares = CVar.Bool(
        "r_igi2_lens_flares",
        true,
        CVarOptions.Archive,
        "I.G.I. 2 retail Lens Flares toggle.");

    /// <summary>Whether the retail Bullet Hit Effects toggle is on.</summary>
    public static readonly BoolCVar BulletHitEffects = CVar.Bool(
        "r_igi2_bullet_hit_effects",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail Bullet Hit Effects toggle. Remembered; nothing reads it.");

    /// <summary>The retail Water Quality: normal, high or highest.</summary>
    public static readonly NumericCVar<int> WaterQuality = CVar.Int(
        "r_igi2_water_quality",
        0,
        0,
        2,
        CVarOptions.Archive,
        "I.G.I. 2 retail Water Quality: 0 normal, 1 high, 2 highest. Remembered; nothing reads it.");

    /// <summary>The retail gamma, as the profile keeps it.</summary>
    /// <remarks>
    /// Not <c>r_gamma</c>: the profile's gamma is retail's own number (whose default is nought),
    /// and the resolve's gamma is a display power curve defaulting to one. Mapping one onto the
    /// other would invent a conversion retail never had; this mirror only remembers the choice
    /// for the screen that shows it.
    /// </remarks>
    public static readonly NumericCVar<float> Gamma = CVar.Float(
        "r_igi2_gamma",
        0f,
        null,
        null,
        CVarOptions.Archive,
        "I.G.I. 2 retail gamma, as the profile keeps it. Remembered; the resolve reads r_gamma, not this.");

    /// <summary>The retail crosshair's opacity, nought to one.</summary>
    public static readonly NumericCVar<float> CrossHairAlpha = CVar.Float(
        "r_igi2_crosshair_alpha",
        1f,
        0f,
        1f,
        CVarOptions.Archive,
        "I.G.I. 2 retail crosshair opacity.");

    /// <summary>Whether the retail crosshair is drawn thick.</summary>
    public static readonly BoolCVar ThickCrossHair = CVar.Bool(
        "r_igi2_crosshair_thick",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail thick-crosshair toggle.");

    /// <summary>The retail crosshair colour's red component, nought to one.</summary>
    public static readonly NumericCVar<float> CrossHairColourR = CVar.Float(
        "r_igi2_crosshair_r",
        1f,
        0f,
        1f,
        CVarOptions.Archive,
        "I.G.I. 2 retail crosshair colour, red component.");

    /// <summary>The retail crosshair colour's green component, nought to one.</summary>
    public static readonly NumericCVar<float> CrossHairColourG = CVar.Float(
        "r_igi2_crosshair_g",
        0.25f,
        0f,
        1f,
        CVarOptions.Archive,
        "I.G.I. 2 retail crosshair colour, green component.");

    /// <summary>The retail crosshair colour's blue component, nought to one.</summary>
    public static readonly NumericCVar<float> CrossHairColourB = CVar.Float(
        "r_igi2_crosshair_b",
        0f,
        0f,
        1f,
        CVarOptions.Archive,
        "I.G.I. 2 retail crosshair colour, blue component.");

    /// <summary>Whether the retail Force Software Vertex Processing toggle is on.</summary>
    public static readonly BoolCVar ForceSoftwareVertexProcessing = CVar.Bool(
        "r_igi2_software_vp",
        false,
        CVarOptions.Archive,
        "I.G.I. 2 retail Force Software Vertex Processing toggle. Remembered; a retail renderer choice with no equivalent here.");
}
