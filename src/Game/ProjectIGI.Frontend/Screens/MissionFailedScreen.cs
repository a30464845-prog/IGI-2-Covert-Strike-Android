using ProjectIGI.Core.Graphics;
using ProjectIGI.Input;
using ProjectIGI.UI;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// The I.G.I. 2 "Mission Failed" dialog, shown upon player death or objective failure: restart the
/// mission, or abandon it and return to the main menu.
/// </summary>
/// <remarks>
/// Back is defined by the existing code and kept as-is: Android Back (or Escape) abandons the mission,
/// exactly like the Abort button. There is no "previous screen" to go back to — the mission is over —
/// so back cannot mean anything gentler.
/// </remarks>
public sealed class MissionFailedScreen : ShellScreen
{
    /// <summary>Initializes a new instance of the <see cref="MissionFailedScreen"/> class.</summary>
    /// <param name="context">The shared shell context.</param>
    public MissionFailedScreen(ShellContext context)
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

        // Back, top-left: abandons the mission, the same as Android Back and the Abort button.
        root.Add(
            ShellBackButton.MenuBack(theme, () => Context.Host.AbandonMission()),
            new Anchor(UiVec2.Zero, new UiVec2(0.30f, 0.12f), new Thickness(24f, 24f, 0f, 0f)));

        // Central frame with a danger accent: opaque dark panel, red hairline.
        var frame = new IgiTacticalFrame(theme, "Mission Failed")
        {
            Width = 840f,
            Height = 440f,
            BorderColor = Bgra32.FromRgb(255, 95, 80),
            BackgroundColor = ShellBackButton.PanelFill,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var contentStack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 24f,
            Width = 720f,
            Margin = new Thickness(0f, 64f, 0f, 24f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        // What the two buttons below do, in words.
        contentStack.AddChild(new Label(
            theme.Body,
            "The mission is over. Restart it, or abandon it and return to the main menu.",
            20f,
            theme.Text)
        {
            Wrap = true,
            HorizontalAlignment = HorizontalAlignment.Center,
        });

        // 1. Under top bar: "Abort the Mission"
        var abortBtn = new IgiMenuButton(theme, "Abort the Mission")
        {
            TextSize = 34f,
            Height = ShellSizes.MinTappable,
            Width = 660f,
            NormalColor = Bgra32.FromRgb(255, 80, 70),
            HoverColor = Bgra32.FromRgb(255, 180, 170),
        };
        abortBtn.Activated += () => Context.Host.AbandonMission();
        contentStack.AddChild(abortBtn);

        // 2. Under that: "Restart Mission"
        var restartBtn = new IgiMenuButton(theme, "Restart Mission")
        {
            TextSize = 34f,
            Height = ShellSizes.MinTappable,
            Width = 660f,
            NormalColor = Bgra32.FromRgb(80, 160, 255),
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        restartBtn.Activated += () => Context.Host.RestartMission();
        contentStack.AddChild(restartBtn);

        frame.AddChild(contentStack);
        root.Add(frame, new Anchor(UiVec2.Zero, UiVec2.One, Thickness.Zero));

        return root;
    }

    /// <inheritdoc/>
    protected override bool HandleInput(UiNavigation nav, InputState input)
    {
        // Back abandons the mission — the behaviour the code already defined. Kept, not invented.
        if (nav.Back || input.Keyboard.WasPressed(KeyCode.Escape))
        {
            Context.Host.AbandonMission();
            return false;
        }

        return base.HandleInput(nav, input);
    }
}
