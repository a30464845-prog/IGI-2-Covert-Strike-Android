using System.Globalization;
using ProjectIGI.Core.Graphics;
using ProjectIGI.Game.Player;
using ProjectIGI.Input;
using ProjectIGI.Rendering;
using ProjectIGI.UI;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Kit.Widgets;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// I.G.I. 2 "Configuration" screen, rebuilt as a section list with drill-down sub-screens:
///
///   Configuration (section list)
///     Save game         (in-mission only; the mission's own save slots)
///     Graphics          (frame rate, resolution, view distance, sun, smooth motion, FPS counter)
///     Graphics quality  (texture sharpness, mip blending, texture quality, muzzle flash, weather, storm)
///     Controls          (touch customizer, controls alpha/sensitivity, invert look, gyroscope)
///     Crosshair         (size, colour, outline)
///     Display &amp; readability (UI Size, Text Size)
///
/// Every setting the old flat list offered survives here with the same CVar binding and the same
/// persistence (live write on change; OK calls SaveSettings + SaveProfiles). Nothing was dropped or
/// re-defaulted; the rows only moved into sections. The old flat list is gone, not reskinned.
///
/// Navigation: one screen instance holds the section in a field and rebuilds its tree on section
/// change (Screen.Invalidate), so the entry-time snapshots are taken once and shared by
/// every sub-screen. Back — the top-left BACK button, the Cancel button, or the Android Back key — is
/// Cancel everywhere in Configuration: it restores those snapshots and closes, never leaving dirty
/// values behind. OK saves; on a sub-screen it saves and returns to the section list, on the list it
/// saves and closes. SECTIONS (sub-screens only) returns to the list without saving or discarding, so
/// live edits stay live until OK or Cancel settles them.
/// </summary>
public sealed class SettingsScreen : ShellScreen
{
    private static readonly int[] FpsCapValues = [30, 60, 90, 120, 0];
    private static readonly string[] FpsCapLabels = ["30 FPS", "60 FPS", "90 FPS", "120 FPS", "UNCAPPED"];
    private static readonly string[] RenderScaleLabels = ["540P (FASTEST)", "720P (PERFORMANCE)", "900P (BALANCED)", "NATIVE (MAX)"];
    private static readonly float[] ViewDistanceValues = [1f, 0.5f, 0.1f, 0.025f];
    private static readonly string[] ViewDistanceLabels = ["FAR", "50%", "MEDIUM", "NEAR"];
    private static readonly int[] AnisotropyValues = [1, 4, 8, 16];
    private static readonly string[] AnisotropyLabels = ["OFF", "4X", "8X", "16X"];
    private static readonly string[] TextureQualityLabels = ["LOW", "MEDIUM", "HIGH"];

    // 48 dp in this screen's own units. The shell is authored at a 1920x1080 reference with
    // GlobalUiScale 1.2, so at a 1080p-high display one design unit is 1.2 physical px; at a
    // ~400 dpi phone (density ~2.625) that is ~0.46 dp per unit, and 48 dp is ~105 units.
    // Every tappable control on this screen — section rows, setting rows, OK/Cancel, BACK,
    // SECTIONS — is this tall, so no target is under the Android 48 dp floor.
    private const float RowHeightUnits = 104f;
    private const float RowWidthUnits = 1150f;
    private const float SectionRowTextSize = 30f;

    /// <summary>Which view of Configuration this screen is showing.</summary>
    private enum Section
    {
        /// <summary>The section list.</summary>
        List,

        /// <summary>The mission's save slots (in-mission only).</summary>
        SaveGame,

        /// <summary>Frame rate, resolution, view distance, sun, smooth motion, FPS counter.</summary>
        Graphics,

        /// <summary>Texture sharpness, mip blending, texture quality, muzzle flash, weather, storm.</summary>
        GraphicsQuality,

        /// <summary>Touch customizer, controls alpha/sensitivity, invert look, gyroscope.</summary>
        Controls,

        /// <summary>Crosshair size, colour, outline.</summary>
        Crosshair,

        /// <summary>UI Size and Text Size.</summary>
        Display,
    }

    // The entry-time snapshots Cancel restores. Not readonly: OK refreshes them to the just-saved
    // values, so a Cancel after an OK reverts to the last saved state instead of silently undoing
    // what OK just wrote to disk (the old code left the live values reverted while the file kept
    // the saved ones — incoherent the moment OK and Cancel were used in one visit).
    private float _initialOpacity;
    private float _initialSensitivity;
    private int _initialFpsCap;
    private bool _initialInvert;
    private bool _initialGyro;
    private float _initialGyroSensitivity;
    private bool _initialInvertGyro;
    private float _initialUiScale;
    private float _initialTextScale;
    private int _initialRenderScale;
    private float _initialViewDistance;
    private bool _initialShowFps;
    private float _initialSunBrightness;
    private bool _initialSmooth;
    private int _initialAnisotropy;
    private bool _initialPointMips;
    private int _initialTextureQuality;
    private float _initialMuzzleFlash;
    private bool _initialWeather;
    private bool _initialStorm;
    private float _initialCrosshairScale;
    private int _initialCrosshairColor;
    private bool _initialCrosshairOutline;

    private Section _section = Section.List;
    private ScrollView? _scroll;
    private UiVec2? _touchDragStart;
    private float _touchDragStartOffset;
    private bool _isDragging;
    private Control? _pendingTapTarget;

    /// <summary>Initializes a new instance of the <see cref="SettingsScreen"/> class.</summary>
    /// <param name="context">The shared shell context.</param>
    public SettingsScreen(ShellContext context)
        : base(context)
    {
        CaptureSnapshots();
    }

    /// <summary>Reads every live value into the snapshots Cancel restores.</summary>
    private void CaptureSnapshots()
    {
        _initialOpacity = Context.Host.TouchOpacity;
        _initialSensitivity = Context.Host.TouchSensitivity;
        _initialFpsCap = ReconstructionCVars.FrameLimit.Value;
        _initialInvert = Context.Config.Active?.InvertMouse ?? false;
        _initialGyro = Context.Config.Active?.GyroEnabled ?? false;
        _initialGyroSensitivity = Context.Config.Active?.GyroSensitivity ?? 0.5f;
        _initialInvertGyro = Context.Config.Active?.InvertGyro ?? false;
        _initialUiScale = DisplayCVars.UiScale.Value;
        _initialTextScale = DisplayCVars.TextScale.Value;
        _initialRenderScale = Context.Host.RenderScaleMode;
        _initialViewDistance = ReconstructionCVars.ViewDistance.Value;
        _initialShowFps = DisplayCVars.ShowFps.Value;
        _initialSunBrightness = LightingCVars.SunBrightness.Value;
        _initialSmooth = FrameCVars.SmoothPresentation.Value;
        _initialAnisotropy = MaterialCVars.Anisotropy.Value;
        _initialPointMips = MaterialCVars.PointMips.Value;
        _initialTextureQuality = MaterialCVars.TextureQuality.Value;
        _initialMuzzleFlash = CombatEffectCVars.MuzzleFlash.Value;
        _initialWeather = WeatherCVars.WeatherEnabled.Value;
        _initialStorm = WeatherCVars.Storm.Value;
        _initialCrosshairScale = HudCVars.CrosshairScale.Value;
        _initialCrosshairColor = HudCVars.CrosshairColor.Value;
        _initialCrosshairOutline = HudCVars.CrosshairOutline.Value;
    }

    /// <summary>Builds this screen's own theme: the shell's colours, with larger text and rows.</summary>
    private static UiTheme LargeTheme(UiTheme shared)
    {
        return new UiTheme(shared.Body, shared.Heading, shared.Mono, shared.Display)
        {
            BodyTextSize = 22f,
            HeadingTextSize = 52f,
            LabelTextSize = 23f,
            CaptionTextSize = 14f,
            LabelTracking = shared.LabelTracking,
            CaptionTracking = shared.CaptionTracking,
            RowHeight = 56f,
            RowDividers = shared.RowDividers,
            GlassBlur = shared.GlassBlur,
            Text = shared.Text,
            TextBright = shared.TextBright,
            TextLabel = shared.TextLabel,
            TextSecondary = shared.TextSecondary,
            TextMuted = shared.TextMuted,
            TextDim = shared.TextDim,
            TextDisabled = shared.TextDisabled,
            Accent = shared.Accent,
            AccentHover = shared.AccentHover,
            OnAccent = shared.OnAccent,
            Panel = shared.Panel,
            FocusFill = shared.FocusFill,
            Border = shared.Border,
            Track = shared.Track,
            Shadow = shared.Shadow,
            Surface = shared.Surface,
            SurfaceRaised = shared.SurfaceRaised,
            Selection = shared.Selection,
            Info = shared.Info,
            Success = shared.Success,
            Warning = shared.Warning,
            Danger = shared.Danger,
            Destructive = shared.Destructive,
            DestructiveBorder = shared.DestructiveBorder,
        };
    }

    /// <inheritdoc/>
    protected override bool HasChrome => false;

    /// <inheritdoc/>
    protected override ShellTab Tab => ShellTab.Settings;

    /// <inheritdoc/>
    public override float BackdropBlur => 0f;

    /// <inheritdoc/>
    protected override UiElement? BuildContent(LayoutContext context)
    {
        // A rebuild (section change) drops the previous tree, so no drag state survives into it.
        _touchDragStart = null;
        _isDragging = false;
        _pendingTapTarget = null;

        // This screen's own theme: the shell's colours, with larger text and rows. The shared theme
        // is never mutated -- the other screens are laid out for its sizes. The frame is already as
        // tall as the 1080 reference allows, so the growth is in width, row height and text.
        UiTheme theme = LargeTheme(Context.Theme);

        Section section = _section;
        if (section == Section.SaveGame && !(Context.InGame && Context.Host.MissionSaves is not null))
        {
            section = Section.List;
            _section = Section.List;
        }

        var root = new Canvas();

        // 1. Logo at Top Center
        var logo = new IgiLogo(theme)
        {
            Margin = new Thickness(0f, 20f, 0f, 0f),
            VerticalAlignment = VerticalAlignment.Top,
            HorizontalAlignment = HorizontalAlignment.Center,
        };
        root.Add(logo, new Anchor(UiVec2.Zero, new UiVec2(1f, 0.20f), Thickness.Zero));

        // 2. Central frame. Opaque dark (alpha 255), one blue hairline: the frame's own background
        // used to be translucent (alpha 240), letting the level show through the panel.
        string title = section switch
        {
            Section.SaveGame => "Configuration - Save game",
            Section.Graphics => "Configuration - Graphics",
            Section.GraphicsQuality => "Configuration - Graphics quality",
            Section.Controls => "Configuration - Controls",
            Section.Crosshair => "Configuration - Crosshair",
            Section.Display => "Configuration - Display & readability",
            _ => "Configuration",
        };
        var frame = new IgiTacticalFrame(theme, title)
        {
            Width = 1280f,
            Height = 880f,
            Margin = new Thickness(0f, 15f, 0f, 0f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
            BackgroundColor = Bgra32.FromRgb(8, 16, 30),
        };

        // The options scroll: a section can hold more rows than the frame shows, so the list lives
        // in a ScrollView and the button bar stays fixed at the bottom of the frame.
        _scroll = new ScrollView(theme)
        {
            Width = 1190f,
            Height = 740f,
            Margin = new Thickness(60f, 42f, 30f, 0f),
            ScrollbarWidth = 14f,
            ScrollbarHitWidth = 56f,
        };

        var stack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 12f,
            Width = 1150f,
        };
        _scroll.SetContent(stack);

        switch (section)
        {
            case Section.List:
                BuildSectionList(stack, theme);
                break;
            case Section.SaveGame:
                BuildSaveGameSection(stack, theme);
                break;
            case Section.Graphics:
                BuildGraphicsSection(stack, theme);
                break;
            case Section.GraphicsQuality:
                BuildGraphicsQualitySection(stack, theme);
                break;
            case Section.Controls:
                BuildControlsSection(stack, theme);
                break;
            case Section.Crosshair:
                BuildCrosshairSection(stack, theme);
                break;
            case Section.Display:
                BuildDisplaySection(stack, theme);
                break;
        }

        frame.AddChild(_scroll);
        frame.AddChild(BuildButtonBar(theme, section != Section.List));
        root.Add(frame, new Anchor(UiVec2.Zero, UiVec2.One, Thickness.Zero));

        // 3. BACK, top-left of the screen, on every view: the visible back control. It is Cancel —
        // it restores the entry-time snapshots and closes — exactly like the Cancel button and the
        // Android Back key. It sits outside the frame, clear of the centred logo and the frame edge.
        var backBtn = new Button(theme, "BACK")
        {
            Accent = ButtonAccent.Ghost,
            Width = 220f,
            Height = RowHeightUnits,
            TextSize = SectionRowTextSize,
            HorizontalAlignment = HorizontalAlignment.Left,
            VerticalAlignment = VerticalAlignment.Top,
        };
        backBtn.Activated += _ =>
        {
            RestoreSnapshots();
            CloseConfig();
        };
        root.Add(backBtn, new Anchor(UiVec2.Zero, UiVec2.Zero, new Thickness(32f, 32f, 0f, 0f)));

        return root;
    }

    /// <summary>The section list: one 48 dp row per section, with the save/cancel rule stated on screen.</summary>
    private void BuildSectionList(StackPanel stack, UiTheme theme)
    {
        var intro = new Label(
            theme.Body,
            "Choose a section. Changes apply as you make them: OK saves them, Back or Cancel discards every change made since Configuration was opened.",
            20f,
            theme.TextSecondary)
        {
            Width = RowWidthUnits,
            Wrap = true,
            Margin = new Thickness(0f, 18f, 0f, 6f),
        };
        stack.AddChild(intro);

        if (Context.InGame && Context.Host.MissionSaves is not null)
        {
            AddSectionRow(stack, theme, "Save game", Section.SaveGame);
        }

        AddSectionRow(stack, theme, "Graphics", Section.Graphics);
        AddSectionRow(stack, theme, "Graphics quality", Section.GraphicsQuality);
        AddSectionRow(stack, theme, "Controls", Section.Controls);
        AddSectionRow(stack, theme, "Crosshair", Section.Crosshair);
        AddSectionRow(stack, theme, "Display & readability", Section.Display);
    }

    /// <summary>One section row: its name, with a chevron that says it opens a sub-screen.</summary>
    private void AddSectionRow(StackPanel stack, UiTheme theme, string title, Section section)
    {
        var row = new Button(theme, title + " >")
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            TextSize = SectionRowTextSize,
        };
        row.Activated += _ => GoToSection(section);
        stack.AddChild(row);
    }

    /// <summary>Save game: the running mission's own saves, as a sub-screen of their own.</summary>
    /// <remarks>
    /// A save is an action, not a setting — tapping a slot writes it at once, and Cancel never
    /// undoes it, so no save state joins the _initial* snapshots or the Cancel restore block. On
    /// hard difficulty the title offers no slots, so the section says so instead of offering one.
    /// Slot rows come from ITitleSaveGames.Slots (Context.Host.MissionSaves, fed by GameHost.Startup)
    /// and save through MissionSaves.Save(slot): the engine already writes the save, this screen only
    /// triggers it. A row shows its slot's mission time (TitleSaveSlot.Description); the date a save
    /// was written is not on that contract — the concrete Igi2MissionSaves.SlotLabel has it, but the
    /// Frontend does not reference the Igi2 assembly — so it is not shown here.
    /// </remarks>
    private void BuildSaveGameSection(StackPanel stack, UiTheme theme)
    {
        if (Context.Host.MissionSaves is not { } saves)
        {
            return;
        }

        var saveSlotButtons = new List<Button>();
        var savesLeftLabel = new Label(theme.Body, string.Empty, 20f, theme.TextSecondary);
        var saveMessageLabel = new Label(theme.Body, string.Empty, 20f, theme.Accent);
        int confirmedSaveSlot = -1;

        void RefreshSaveSection()
        {
            IReadOnlyList<TitleSaveSlot> slots = saves.Slots;
            for (int i = 0; i < saveSlotButtons.Count && i < slots.Count; i++)
            {
                saveSlotButtons[i].Text = SaveSlotCaption(slots[i]);
            }

            int left = saves.SavesLeft;
            savesLeftLabel.Text = left < 0
                ? string.Empty
                : string.Create(CultureInfo.InvariantCulture, $"Saves left this mission: {left}");
        }

        foreach (TitleSaveSlot slot in saves.Slots)
        {
            int number = slot.Slot;
            var saveButton = new Button(theme, SaveSlotCaption(slot))
            {
                Width = RowWidthUnits,
                Height = RowHeightUnits,
            };
            saveButton.Activated += _ =>
            {
                // Overwrite asks twice, the two-tap confirm from MissionSavesScreen.Choose: the
                // first tap on a slot that already holds a save only warns, the second writes.
                if (saves.SavesLeft == 0)
                {
                    confirmedSaveSlot = -1;
                    saveMessageLabel.Text = "No saves are left for this mission.";
                    return;
                }

                TitleSaveSlot current = default;
                foreach (TitleSaveSlot held in saves.Slots)
                {
                    if (held.Slot == number)
                    {
                        current = held;
                        break;
                    }
                }

                if (current.IsUsed && confirmedSaveSlot != number)
                {
                    confirmedSaveSlot = number;
                    saveMessageLabel.Text = string.Create(
                        CultureInfo.InvariantCulture,
                        $"Slot {number + 1} holds a save - mission time {current.Description}. Choose it again to overwrite.");
                    return;
                }

                confirmedSaveSlot = -1;
                saveMessageLabel.Text = saves.Save(number) ? "Saving complete." : "Saving failed.";
                RefreshSaveSection();
            };
            saveSlotButtons.Add(saveButton);
            stack.AddChild(saveButton);
        }

        stack.AddChild(savesLeftLabel);
        stack.AddChild(saveMessageLabel);
        if (saveSlotButtons.Count == 0)
        {
            saveMessageLabel.Text = "This difficulty keeps no saves.";
        }

        RefreshSaveSection();
    }

    /// <summary>
    /// Graphics: every graphics option that actually changes the picture on the Android path
    /// (first-run preset Vanilla: the original's forward path straight to the back buffer, no
    /// offscreen scene, no Resolve pass). Rows that only run on the deferred/HDR path are
    /// deliberately not here.
    /// </summary>
    private void BuildGraphicsSection(StackPanel stack, UiTheme theme)
    {
        // ── Max Frame Rate (FPS Cap) ─────────────────────────────────────
        // The default is uncapped (0): the CVar's own default and the first-run value, and the loop
        // holds a picked cap strictly (see BeginFramePass). A value the cycler does not offer shows
        // the nearest offered cap rather than claiming Uncapped; the stored value itself is left alone
        // until a cap is picked.
        int currentFps = ReconstructionCVars.FrameLimit.Value;
        int selectedFpsIndex = Array.IndexOf(FpsCapValues, currentFps);
        if (selectedFpsIndex < 0)
        {
            int nearest = 0;
            for (int i = 1; i < FpsCapValues.Length; i++)
            {
                if (Math.Abs(FpsCapValues[i] - currentFps) < Math.Abs(FpsCapValues[nearest] - currentFps))
                {
                    nearest = i;
                }
            }

            selectedFpsIndex = nearest;
        }

        var fpsCycler = new OptionCycler(theme, "Max Frame Rate", FpsCapLabels, selectedFpsIndex)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            ContentWidth = 320f,
        };
        fpsCycler.SelectionChanged += index =>
        {
            int cap = FpsCapValues[index];
            ReconstructionCVars.FrameLimit.Value = cap;
        };
        stack.AddChild(fpsCycler);

        // ── Render Resolution Quality ──────────────────────────────────────
        int currentRes = Context.Host.RenderScaleMode;
        var resCycler = new OptionCycler(theme, "Resolution Quality", RenderScaleLabels, Math.Clamp(currentRes, 0, 3))
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            ContentWidth = 320f,
        };
        resCycler.SelectionChanged += index =>
        {
            Context.Host.RenderScaleMode = index;
        };
        stack.AddChild(resCycler);

        // ── View Distance: how far the world draws ────────────────────────
        // Shortens the far plane: Far is the original's 100 km, 50% is 50 km, Medium 10 km, Near 2.5 km. The
        // original's own fog hides everything past about two and a half kilometres anyway, so Near
        // loses almost nothing visible and skips drawing what the fog would have hidden. The sky dome
        // sizes itself to the far plane, so it stays put, and the held weapon sits centimetres away,
        // so a 2.5 km far plane still contains it entirely.
        float currentViewDistance = ReconstructionCVars.ViewDistance.Value;
        int selectedViewDistanceIndex = 0;
        for (int i = 0; i < ViewDistanceValues.Length; i++)
        {
            if (Math.Abs(ViewDistanceValues[i] - currentViewDistance) < Math.Abs(ViewDistanceValues[selectedViewDistanceIndex] - currentViewDistance))
            {
                selectedViewDistanceIndex = i;
            }
        }

        var viewDistanceCycler = new OptionCycler(theme, "View Distance", ViewDistanceLabels, selectedViewDistanceIndex)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            ContentWidth = 320f,
            Tooltip = "How far the world draws. Near (2.5 km) skips what the original's fog hides anyway; 50% is 50 km; Far is the original's 100 km.",
        };
        viewDistanceCycler.SelectionChanged += index =>
        {
            ReconstructionCVars.ViewDistance.Value = ViewDistanceValues[index];
        };
        stack.AddChild(viewDistanceCycler);

        // ── Sun: how bright the level sun reads ───────────────────────────
        // Scales the authored sun that lights the models and the world's bakes.
        // Above 100% dark areas read brighter; 100% is the level as authored.
        // (Display gamma only runs in the Resolve pass, which the vanilla path
        // Android uses never has, so this is the brightness knob that works here.)
        float initialSun = LightingCVars.SunBrightness.Value;
        var sunSlider = new Slider(theme, "Sun", 50f, 300f, (int)Math.Round(initialSun * 100f), 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        sunSlider.ValueChanged += value =>
        {
            LightingCVars.SunBrightness.Value = Math.Clamp(value / 100f, 0.5f, 3f);
        };
        stack.AddChild(sunSlider);

        // ── Smooth Motion: draw at the display's rate, not the original's 30 Hz ──
        // Interpolates between the original's fixed 30 ticks a second. Off restores
        // the original cadence (and IGI 2's retail mouse filtering and turn-speed cap).
        bool smoothState = FrameCVars.SmoothPresentation.Value;
        var smoothToggle = new Toggle(theme, "Smooth Motion", smoothState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Draw the world at your display's rate instead of the original's fixed 30 steps a second. Off restores the original cadence.",
        };
        smoothToggle.ValueChanged += val =>
        {
            FrameCVars.SmoothPresentation.Value = val;
        };
        stack.AddChild(smoothToggle);

        // ── Show FPS Counter Overlay ───────────────────────────────────────
        bool showFpsState = DisplayCVars.ShowFps.Value;
        var fpsToggle = new Toggle(theme, "Show FPS Counter", showFpsState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        fpsToggle.ValueChanged += val =>
        {
            DisplayCVars.ShowFps.Value = val;
        };
        stack.AddChild(fpsToggle);
    }

    /// <summary>
    /// Graphics quality: texture sharpness is the knob for "snow looks too smooth" — vanilla pins
    /// anisotropy to 1 (off), and without it the ground smears towards the horizon. The rest are the
    /// combat/weather picture knobs that are live on this path. The texture rows apply at once now —
    /// changing one re-resolves the samplers of textures already loaded — instead of waiting for the
    /// next level.
    /// </summary>
    private void BuildGraphicsQualitySection(StackPanel stack, UiTheme theme)
    {
        // ── Texture Sharpness: anisotropic filtering (Off / 4x / 8x / 16x) ─────
        int currentAnisotropy = MaterialCVars.Anisotropy.Value;
        int selectedAnisotropyIndex = Array.IndexOf(AnisotropyValues, currentAnisotropy);
        if (selectedAnisotropyIndex < 0)
        {
            selectedAnisotropyIndex = 0;
        }

        var anisotropyCycler = new OptionCycler(theme, "Texture Sharpness", AnisotropyLabels, selectedAnisotropyIndex)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            ContentWidth = 320f,
            Tooltip = "How sharp the ground stays into the distance. Off is the original's look; higher keeps snow and terrain crisp towards the horizon. Applies immediately.",
        };
        anisotropyCycler.SelectionChanged += index =>
        {
            MaterialCVars.Anisotropy.Value = AnisotropyValues[index];
        };
        stack.AddChild(anisotropyCycler);

        // ── Blend Mip Levels: linear mip blending instead of the original's nearest ──
        bool mipBlendState = !MaterialCVars.PointMips.Value;
        var mipBlendToggle = new Toggle(theme, "Blend Mip Levels", mipBlendState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Blend between mip levels instead of taking the nearest one, as the original does. Off is the original's slightly crisper, slightly shimmering look. Applies immediately.",
        };
        mipBlendToggle.ValueChanged += val =>
        {
            MaterialCVars.PointMips.Value = !val;
        };
        stack.AddChild(mipBlendToggle);

        // ── Texture Quality: how sharp textures stay at a distance ───────────
        // A bias on the mip selection, on top of what the render scale asks for: High samples one
        // level sharper, Low one softer. It reaches textures already loaded, so it shows at once.
        // Vulkan only -- WebGPU has no mip-bias sampler state and samples unbiased.
        int currentTextureQuality = Math.Clamp(MaterialCVars.TextureQuality.Value, 0, 2);
        var textureQualityCycler = new OptionCycler(theme, "Texture Quality", TextureQualityLabels, currentTextureQuality)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            ContentWidth = 320f,
            Tooltip = "How sharp textures stay at a distance. High samples the sharper mip levels; Low softens them. Applies immediately, on Vulkan.",
        };
        textureQualityCycler.SelectionChanged += index =>
        {
            MaterialCVars.TextureQuality.Value = index;
        };
        stack.AddChild(textureQualityCycler);

        // ── Muzzle Flash: how bright the flame at the barrel is ───────────────
        float initialMuzzleFlash = CombatEffectCVars.MuzzleFlash.Value;
        var muzzleSlider = new Slider(theme, "Muzzle Flash", 0f, 100f, (int)Math.Round(initialMuzzleFlash * 100f), 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "How bright the flame at the barrel is. 100% is the original's; 0 removes it.",
        };
        muzzleSlider.ValueChanged += value =>
        {
            CombatEffectCVars.MuzzleFlash.Value = Math.Clamp(value / 100f, 0f, 1f);
        };
        stack.AddChild(muzzleSlider);

        // Impact Effects and Impact Particles are deliberately NOT here: both are I.G.I. 1
        // systems with no I.G.I. 2 input. The retail impacts view is only registered by the I.G.I. 1
        // presenter, so the toggle gated a null draw; the particle bursts only ever came from the
        // I.G.I. 1 rig's ballistics, which never fires on this title, and no I.G.I. 2 code calls the
        // burst path. Restoring them needs I.G.I. 2 gunfire impact recording plus an I.G.I. 2
        // MissionEffects presenter, as separate work.

        // ── Weather: the rain or snow the level authors gave the mission ──────
        bool weatherState = WeatherCVars.WeatherEnabled.Value;
        var weatherToggle = new Toggle(theme, "Weather", weatherState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Draw the rain or snow the level authors gave each mission.",
        };
        weatherToggle.ValueChanged += val =>
        {
            WeatherCVars.WeatherEnabled.Value = val;
        };
        stack.AddChild(weatherToggle);

        // ── Storm Effects: the remastered particle storm instead of the original's rain band ──
        bool stormState = WeatherCVars.Storm.Value;
        var stormToggle = new Toggle(theme, "Storm Effects", stormState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Wind-blown storm rain with splashes and lightning, instead of the original's fixed rain band. Only where a level rains.",
        };
        stormToggle.ValueChanged += val =>
        {
            WeatherCVars.Storm.Value = val;
        };
        stack.AddChild(stormToggle);
    }

    /// <summary>
    /// Controls: the touch customizer, controls alpha/sensitivity, invert look, and the gyroscope
    /// rows — which used to sit under "Graphics quality" with no header of their own.
    /// </summary>
    private void BuildControlsSection(StackPanel stack, UiTheme theme)
    {
        // ── On-Screen Touch Controls Customizer ───────────────────────────
        var customizeBtn = new Button(theme, "CUSTOMIZE ON-SCREEN CONTROLS")
        {
            Accent = ButtonAccent.Ghost,
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            TextSize = 36f,
        };
        customizeBtn.Activated += _ => Context.Host.CustomizeTouchControls();
        stack.AddChild(customizeBtn);

        // ── Controls Alpha Slider (20% to 100%) ───────────────────────────
        int initialPct = (int)Math.Round(Context.Host.TouchOpacity * 100f);
        var alphaSlider = new Slider(theme, "Controls Alpha", 20f, 100f, initialPct, 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        alphaSlider.ValueChanged += value =>
        {
            float norm = Math.Clamp(value / 100f, 0.20f, 1.0f);
            Context.Host.TouchOpacity = norm;
        };
        stack.AddChild(alphaSlider);

        // ── Touch Sensitivity Slider (20% to 300%) ────────────────────────
        int initialSensPct = (int)Math.Round(Context.Host.TouchSensitivity * 100f);
        var sensSlider = new Slider(theme, "Touch Sensitivity", 20f, 300f, initialSensPct, 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        sensSlider.ValueChanged += value =>
        {
            float norm = Math.Clamp(value / 100f, 0.20f, 3.0f);
            Context.Host.TouchSensitivity = norm;
        };
        stack.AddChild(sensSlider);

        // ── Invert Mouse / Look Pitch ──────────────────────────────────────
        bool invertState = Context.Config.Active?.InvertMouse ?? false;
        var invertToggle = new Toggle(theme, "Invert Look / Mouse", invertState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        invertToggle.ValueChanged += val =>
        {
            if (Context.Config.Active is { } profile)
            {
                profile.InvertMouse = val;
            }
        };
        stack.AddChild(invertToggle);

        // ── Gyroscope aim (Android only; tilt the phone to aim) ───────────
        bool gyroState = Context.Config.Active?.GyroEnabled ?? false;
        var gyroToggle = new Toggle(theme, "Gyroscope aim", gyroState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Tilt the phone to aim. Only on Android, and only while playing.",
        };
        gyroToggle.ValueChanged += val =>
        {
            if (Context.Config.Active is { } profile)
            {
                profile.GyroEnabled = val;
            }
        };
        stack.AddChild(gyroToggle);

        // ── Gyroscope sensitivity ──────────────────────────────────────────
        float gyroSensState = Context.Config.Active?.GyroSensitivity ?? 0.5f;
        var gyroSensSlider = new Slider(theme, "Gyroscope sensitivity", 0f, 1f, gyroSensState, 0.05f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Format = v => string.Create(
                CultureInfo.InvariantCulture,
                $"{MouseLookSettings.FromSensitivity(v, invertPitch: false).TurnDistanceCentimetres():0} cm/360°"),
            Tooltip = "How fast the view turns when you tilt the phone.\n\nSame scale as mouse sensitivity — the readout is how far a full turn takes.",
        };
        gyroSensSlider.ValueChanged += value =>
        {
            if (Context.Config.Active is { } profile)
            {
                profile.GyroSensitivity = value;
            }
        };
        stack.AddChild(gyroSensSlider);

        // ── Invert gyroscope ───────────────────────────────────────────────
        bool invertGyroState = Context.Config.Active?.InvertGyro ?? false;
        var invertGyroToggle = new Toggle(theme, "Invert gyroscope", invertGyroState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
            Tooltip = "Tilt the phone and the view turns the opposite way, left/right and forward/back.",
        };
        invertGyroToggle.ValueChanged += val =>
        {
            if (Context.Config.Active is { } profile)
            {
                profile.InvertGyro = val;
            }
        };
        stack.AddChild(invertGyroToggle);
    }

    /// <summary>
    /// Crosshair: size, colour and outline. The sight is a hairline at 1px on a dense display;
    /// these make it readable. They apply to whichever sight is drawn: the original's lines and
    /// the remastered cross alike.
    /// </summary>
    private void BuildCrosshairSection(StackPanel stack, UiTheme theme)
    {
        float initialCrosshair = HudCVars.CrosshairScale.Value;
        var crosshairSlider = new Slider(theme, "Crosshair size", 50f, 300f, (int)Math.Round(initialCrosshair * 100f), 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        crosshairSlider.ValueChanged += value =>
        {
            HudCVars.CrosshairScale.Value = Math.Clamp(value / 100f, 0.5f, 3f);
        };
        stack.AddChild(crosshairSlider);

        var crosshairColourBtn = new Button(theme, "Crosshair colour: " + CrosshairPalette.Names[HudCVars.CrosshairColor.Value])
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        crosshairColourBtn.Activated += _ =>
        {
            int next = (HudCVars.CrosshairColor.Value + 1) % CrosshairPalette.Names.Length;
            HudCVars.CrosshairColor.Value = next;
            crosshairColourBtn.Text = "Crosshair colour: " + CrosshairPalette.Names[next];
        };
        stack.AddChild(crosshairColourBtn);

        bool crosshairOutlineState = HudCVars.CrosshairOutline.Value;
        var crosshairOutlineToggle = new Toggle(theme, "Crosshair outline", crosshairOutlineState)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        crosshairOutlineToggle.ValueChanged += val =>
        {
            HudCVars.CrosshairOutline.Value = val;
        };
        stack.AddChild(crosshairOutlineToggle);
    }

    /// <summary>
    /// Display &amp; readability: UI Size and Text Size, as a section of their own instead of buried
    /// mid-list — they are the escape hatch for the small-text problem, so they get a caption that
    /// says what they scale.
    /// </summary>
    private void BuildDisplaySection(StackPanel stack, UiTheme theme)
    {
        var caption = new Label(
            theme.Body,
            "UI Size scales every shell screen, this one included. Text Size scales the text on the rows. Both apply at once and survive a relaunch.",
            20f,
            theme.TextSecondary)
        {
            Width = RowWidthUnits,
            Wrap = true,
            Margin = new Thickness(0f, 18f, 0f, 6f),
        };
        stack.AddChild(caption);

        // ── UI Size Slider (80% to 200%) ───────────────────────────────────
        // Backed by r_ui_scale, so the size survives a relaunch; the host hands the value to the
        // layout as its user scale, which is what makes the whole shell -- this screen included --
        // draw larger. The old version wrote a static nothing ever saved.
        int initialUiPct = (int)Math.Round(DisplayCVars.UiScale.Value * 100f);
        var uiSizeSlider = new Slider(theme, "UI Size", 80f, 200f, initialUiPct, 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        uiSizeSlider.ValueChanged += value =>
        {
            DisplayCVars.UiScale.Value = Math.Clamp(value / 100f, 0.8f, 2.0f);
        };
        stack.AddChild(uiSizeSlider);

        // ── Text Size Slider (80% to 150%) ─────────────────────────────────
        // Backed by r_text_scale, so it survives a relaunch too; the row widgets multiply the size
        // they resolve by it as they draw, so it takes effect live. It used to write a static no
        // text drawing ever read, so the slider did nothing at all.
        int initialTextPct = (int)Math.Round(DisplayCVars.TextScale.Value * 100f);
        var textSizeSlider = new Slider(theme, "Text Size", 80f, 150f, initialTextPct, 5f)
        {
            Width = RowWidthUnits,
            Height = RowHeightUnits,
        };
        textSizeSlider.ValueChanged += value =>
        {
            DisplayCVars.TextScale.Value = Math.Clamp(value / 100f, 0.8f, 1.5f);
        };
        stack.AddChild(textSizeSlider);
    }

    /// <summary>
    /// The bottom bar: OK and Cancel at the bottom-right on every view. Sub-screens also get
    /// SECTIONS at the bottom-left, which returns to the section list without saving or discarding.
    /// </summary>
    private FlexPanel BuildButtonBar(UiTheme theme, bool showSections)
    {
        var btnBar = new FlexPanel
        {
            Orientation = Orientation.Horizontal,
            Gap = 28f,
            HorizontalAlignment = HorizontalAlignment.Stretch,
            VerticalAlignment = VerticalAlignment.Bottom,
            Margin = new Thickness(32f, 0f, 32f, 16f),
        };

        if (showSections)
        {
            var sectionsBtn = new Button(theme, "SECTIONS")
            {
                Accent = ButtonAccent.Ghost,
                Width = 240f,
                Height = RowHeightUnits,
                TextSize = 28f,
            };
            sectionsBtn.Activated += _ => GoToList();
            btnBar.Add(sectionsBtn);
        }

        // Pushes OK/Cancel to the right edge.
        btnBar.Add(new Panel(), grow: 1f);

        var okBtn = new IgiMenuButton(theme, "OK")
        {
            TextSize = 36f,
            Height = RowHeightUnits,
            Width = 220f,
            NormalColor = Bgra32.FromRgb(80, 160, 255),
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        okBtn.Activated += () =>
        {
            SaveAll();
            if (_section == Section.List)
            {
                CloseConfig();
            }
            else
            {
                GoToList();
            }
        };
        btnBar.Add(okBtn);

        var cancelBtn = new IgiMenuButton(theme, "Cancel")
        {
            TextSize = 36f,
            Height = RowHeightUnits,
            Width = 220f,
            NormalColor = Bgra32.FromRgb(80, 160, 255),
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        cancelBtn.Activated += () =>
        {
            RestoreSnapshots();
            CloseConfig();
        };
        btnBar.Add(cancelBtn);

        return btnBar;
    }

    /// <summary>Writes every setting to disk, and moves the Cancel snapshots to what was just saved.</summary>
    private void SaveAll()
    {
        Context.Host.SaveSettings();

        // Profiles carry Invert, Gyro and gyro sensitivity, which settings.cfg never wrote: OK
        // used to leave them to the save on exit, so they were lost whenever the app was killed
        // or swiped away after OK instead of quit cleanly.
        Context.Host.SaveProfiles();
        CaptureSnapshots();
    }

    /// <summary>Restores every live value to the entry-time (or last-OK) snapshots.</summary>
    /// <remarks>
    /// Save slots write at once and are explicitly exempt: a save is an action, not a setting.
    /// </remarks>
    private void RestoreSnapshots()
    {
        Context.Host.TouchOpacity = _initialOpacity;
        Context.Host.TouchSensitivity = _initialSensitivity;
        Context.Host.RenderScaleMode = _initialRenderScale;
        ReconstructionCVars.ViewDistance.Value = _initialViewDistance;
        ReconstructionCVars.FrameLimit.Value = _initialFpsCap;
        DisplayCVars.UiScale.Value = _initialUiScale;
        DisplayCVars.TextScale.Value = _initialTextScale;
        DisplayCVars.ShowFps.Value = _initialShowFps;
        LightingCVars.SunBrightness.Value = _initialSunBrightness;
        FrameCVars.SmoothPresentation.Value = _initialSmooth;
        MaterialCVars.Anisotropy.Value = _initialAnisotropy;
        MaterialCVars.PointMips.Value = _initialPointMips;
        MaterialCVars.TextureQuality.Value = _initialTextureQuality;
        CombatEffectCVars.MuzzleFlash.Value = _initialMuzzleFlash;
        WeatherCVars.WeatherEnabled.Value = _initialWeather;
        WeatherCVars.Storm.Value = _initialStorm;
        HudCVars.CrosshairScale.Value = _initialCrosshairScale;
        HudCVars.CrosshairColor.Value = _initialCrosshairColor;
        HudCVars.CrosshairOutline.Value = _initialCrosshairOutline;
        if (Context.Config.Active is { } profile)
        {
            profile.InvertMouse = _initialInvert;
            profile.GyroEnabled = _initialGyro;
            profile.GyroSensitivity = _initialGyroSensitivity;
            profile.InvertGyro = _initialInvertGyro;
        }
    }

    /// <summary>Opens a sub-screen: the same instance rebuilds its tree for the section.</summary>
    private void GoToSection(Section section)
    {
        _section = section;
        Invalidate();
    }

    /// <summary>Returns to the section list without saving or discarding.</summary>
    private void GoToList()
    {
        _section = Section.List;
        Invalidate();
    }

    /// <summary>A save slot's row as the settings screen shows it: its number and what it holds, or that it is empty.</summary>
    private static string SaveSlotCaption(TitleSaveSlot slot) =>
        slot.IsUsed
            ? string.Create(CultureInfo.InvariantCulture, $"Slot {slot.Slot + 1:00} - Mission time {slot.Description}")
            : string.Create(CultureInfo.InvariantCulture, $"Slot {slot.Slot + 1:00} - Empty");

    private void CloseConfig()
    {
        if (Context.InGame)
        {
            Context.Stack.Reset(new PauseScreen(Context));
        }
        else if (Context.SettingsFromRetailMenu)
        {
            // Opened from the retail main menu, not from the shell's own main menu:
            // the player never saw the shell's landing page, so going back means the
            // shell is put away and the retail menu is on screen again.
            Context.SettingsFromRetailMenu = false;
            Context.Stack.Reset(new MainMenuScreen(Context));
            Context.Host.ReturnToRetailMenu();
        }
        else
        {
            Context.Stack.Reset(new MainMenuScreen(Context));
        }
    }

    /// <inheritdoc/>
    protected override bool HandleInput(UiNavigation nav, InputState input)
    {
        // Back is Cancel everywhere in Configuration: restore the snapshots and close, so a
        // visit that changed sliders never leaves dirty values applied and unsaved.
        if (nav.Back)
        {
            RestoreSnapshots();
            CloseConfig();
            return false;
        }

        // Drag to scroll the options list, mirroring the mission list: a drag scrolls, a
        // tap still activates the control under the pointer.
        if (_scroll is not null)
        {
            var pointer = new UiVec2(input.Mouse.X, input.Mouse.Y);
            bool insideScroll = _scroll.Bounds.Contains(pointer);

            if (input.Mouse.WasPressed(MouseButton.Left))
            {
                if (insideScroll && !_scroll.IsOverScrollbar(pointer))
                {
                    _touchDragStart = pointer;
                    _touchDragStartOffset = _scroll.ScrollOffset;
                    _isDragging = false;
                    _pendingTapTarget = Focus?.FocusAt(pointer) as Control;
                    return false;
                }
            }
            else if (_touchDragStart is { } start && input.Mouse.IsDown(MouseButton.Left))
            {
                float dy = pointer.Y - start.Y;
                if (!_isDragging && MathF.Abs(dy) > 10f)
                {
                    _isDragging = true;
                }

                if (_isDragging)
                {
                    _scroll.ScrollOffset = _touchDragStartOffset - dy;
                    return false;
                }
            }
            else if (input.Mouse.WasReleased(MouseButton.Left) || !input.Mouse.IsDown(MouseButton.Left))
            {
                if (_touchDragStart is not null)
                {
                    _touchDragStart = null;
                    if (!_isDragging)
                    {
                        _pendingTapTarget?.ActivateAt(pointer);
                    }
                    _isDragging = false;
                    _pendingTapTarget = null;
                    return false;
                }
            }
        }

        return base.HandleInput(nav, input);
    }
}
