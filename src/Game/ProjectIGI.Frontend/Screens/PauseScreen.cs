using ProjectIGI.Core.Graphics;
using ProjectIGI.Input;
using ProjectIGI.UI;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// Project I.G.I. 2 "Paused" menu:
/// Centred opaque tactical dialog over the suspended mission, offering:
/// Resume, Restart Mission, Customize Controls, Configuration, and Abort Mission.
/// Rows are 104 units tall (48 dp at the 1080p-high reference); the visible back
/// control top-left resumes, exactly like Back / Escape.
/// </summary>
/// <remarks>
/// No CONSOLE row: the host plumbing that used to open the console from here
/// (IShellHost.OpenConsole, added by PR #86) is not in live main, so there is no
/// call a pause row could make — restoring it needs the host side back first.
/// </remarks>
public sealed class PauseScreen : ShellScreen
{
    /// <summary>Initializes a new instance of the <see cref="PauseScreen"/> class.</summary>
    /// <param name="context">The shared shell context.</param>
    public PauseScreen(ShellContext context)
        : base(context)
    {
    }

    /// <inheritdoc/>
    protected override bool HasChrome => false;

    /// <inheritdoc/>
    protected override ShellTab Tab => ShellTab.Home;

    /// <inheritdoc/>
    public override float BackdropBlur => 4f;

    /// <inheritdoc/>
    protected override UiElement? BuildContent(LayoutContext context)
    {
        UiTheme theme = Context.Theme;

        var root = new Canvas();

        // Visible back control, top-left, 48 dp (104 units at the 1080p-high
        // reference): an opaque chip with the accent hairline, so the label stays
        // readable over the blurred mission behind it. Back = Resume, same as the
        // Back key / Escape handled below.
        var backFrame = new IgiTacticalFrame(theme, string.Empty)
        {
            Width = 220f,
            Height = 104f,
            BackgroundColor = Bgra32.FromRgb(8, 16, 30),
            HorizontalAlignment = HorizontalAlignment.Left,
            VerticalAlignment = VerticalAlignment.Top,
        };
        var backBtn = new IgiMenuButton(theme, "< BACK")
        {
            TextSize = 30f,
            Height = 88f,
            Width = 200f,
        };
        backBtn.Activated += () => Context.Host.ResumeMission();
        backFrame.AddChild(backBtn);
        root.Add(backFrame, new Anchor(UiVec2.Zero, new UiVec2(0.2f, 0.15f), new Thickness(16f, 16f, 0f, 0f)));

        // Central opaque tactical dialog ("Paused"). Background is the pinned
        // opaque dark, not the frame's translucent default.
        var frame = new IgiTacticalFrame(theme, "Paused")
        {
            Width = 880f,
            Height = 720f,
            BackgroundColor = Bgra32.FromRgb(8, 16, 30),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var menuStack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 22f,
            Width = 780f,
            Margin = new Thickness(0f, 68f, 0f, 20f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        // Rows are 104 units tall: 48 dp at the 1080p-high reference (Scale 1.2).
        var resumeBtn = new IgiMenuButton(theme, "RESUME") { TextSize = 34f, Height = 104f, Width = 740f };
        resumeBtn.Activated += () => Context.Host.ResumeMission();
        menuStack.AddChild(resumeBtn);

        var restartBtn = new IgiMenuButton(theme, "RESTART MISSION") { TextSize = 34f, Height = 104f, Width = 740f };
        restartBtn.Activated += () => Context.Host.RestartMission();
        menuStack.AddChild(restartBtn);

        var customBtn = new IgiMenuButton(theme, "CUSTOMIZE CONTROLS") { TextSize = 34f, Height = 104f, Width = 740f };
        customBtn.Activated += () => Context.Host.CustomizeTouchControls();
        menuStack.AddChild(customBtn);

        var configBtn = new IgiMenuButton(theme, "CONFIGURATION") { TextSize = 34f, Height = 104f, Width = 740f };
        configBtn.Activated += () => Context.Stack.Reset(new SettingsScreen(Context));
        menuStack.AddChild(configBtn);

        var abortBtn = new IgiMenuButton(theme, "ABORT MISSION")
        {
            TextSize = 34f,
            Height = 104f,
            Width = 740f,
            NormalColor = Bgra32.FromRgb(255, 95, 80),
            HoverColor = Bgra32.FromRgb(255, 180, 170),
        };
        abortBtn.Activated += () => Context.Host.AbandonMission();
        menuStack.AddChild(abortBtn);

        frame.AddChild(menuStack);
        root.Add(frame, new Anchor(UiVec2.Zero, UiVec2.One, Thickness.Zero));

        return root;
    }

    /// <inheritdoc/>
    protected override bool HandleInput(UiNavigation nav, InputState input)
    {
        if (nav.Back || input.Keyboard.WasPressed(KeyCode.Escape))
        {
            Context.Host.ResumeMission();
            return false;
        }

        return base.HandleInput(nav, input);
    }
}
