using ProjectIGI.Core.Graphics;
using ProjectIGI.Input;
using ProjectIGI.UI;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// The I.G.I. 2 shell home page: the game logo over a dark panel holding "Play I.G.I. 2",
/// "Configuration" and "Quit", with Read Me and Credits as dismissable dialogs. Back quits the game:
/// this is the root page, so there is nowhere back to go to.
/// </summary>
public sealed class MainMenuScreen : ShellScreen
{
    private IgiBorderedBox? _infoDialog;
    private Label? _infoDialogTitle;
    private Label? _infoDialogText;
    private IgiMenuButton? _infoDialogClose;
    private Panel? _infoDialogScrim;
    private bool _infoDialogOpen;

    /// <summary>Initializes a new instance of the <see cref="MainMenuScreen"/> class.</summary>
    /// <param name="context">The shared shell context.</param>
    public MainMenuScreen(ShellContext context)
        : base(context)
    {
    }

    /// <inheritdoc/>
    protected override bool HasChrome => false;

    /// <inheritdoc/>
    protected override ShellTab Tab => ShellTab.Home;

    /// <inheritdoc/>
    public override float BackdropBlur => 0f;

    /// <inheritdoc/>
    protected override UiElement? BuildContent(LayoutContext context)
    {
        UiTheme theme = Context.Theme;

        var root = new Canvas();

        // Back, top-left: on the root page back quits, the same as the Quit button.
        root.Add(
            ShellBackButton.MenuBack(theme, () => Context.Host.Quit()),
            new Anchor(UiVec2.Zero, new UiVec2(0.30f, 0.12f), new Thickness(24f, 24f, 0f, 0f)));

        // 1. Logo at Top Center
        var logo = new IgiLogo(theme)
        {
            Margin = new Thickness(0f, 24f, 0f, 0f),
            VerticalAlignment = VerticalAlignment.Top,
            HorizontalAlignment = HorizontalAlignment.Center,
        };
        root.Add(logo, new Anchor(UiVec2.Zero, new UiVec2(1f, 0.22f), Thickness.Zero));

        // 2. Central Tactical Box ("Main Menu"): opaque dark panel, blue hairline.
        var frame = new IgiTacticalFrame(theme, "Main Menu")
        {
            Width = 920f,
            Height = 720f,
            BackgroundColor = ShellBackButton.PanelFill,
            Margin = new Thickness(0f, 40f, 0f, 0f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var menuStack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 20f,
            Width = 820f,
            Margin = new Thickness(0f, 54f, 0f, 16f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var playBtn = new IgiMenuButton(theme, "Play I.G.I. 2") { TextSize = 40f, Height = ShellSizes.MinTappable, Width = 760f };
        playBtn.Activated += () => Context.Stack.Reset(new CampaignScreen(Context));
        menuStack.AddChild(playBtn);

        var configBtn = new IgiMenuButton(theme, "Configuration") { TextSize = 40f, Height = ShellSizes.MinTappable, Width = 760f };
        configBtn.Activated += () => Context.Stack.Reset(new SettingsScreen(Context));
        menuStack.AddChild(configBtn);

        // Quit is a way out, not a destination: same height, but smaller and muted.
        var quitBtn = new IgiMenuButton(theme, "Quit")
        {
            TextSize = 32f,
            Height = ShellSizes.MinTappable,
            Width = 760f,
            NormalColor = Bgra32.FromRgb(150, 175, 190),
            HoverColor = Bgra32.FromRgb(235, 242, 250),
        };
        quitBtn.Activated += () => Context.Host.Quit();
        menuStack.AddChild(quitBtn);

        // Bottom links: "Read Me" and "Credits" side by side, in the one blue.
        var subStack = new StackPanel
        {
            Orientation = Orientation.Horizontal,
            Spacing = 16f,
            Width = 820f,
            Margin = new Thickness(0f, 26f, 0f, 12f),
            HorizontalAlignment = HorizontalAlignment.Center,
        };

        var readmeBtn = new IgiMenuButton(theme, "Read Me")
        {
            TextSize = 28f,
            Height = ShellSizes.MinTappable,
            Width = 402f,
            NormalColor = ShellBackButton.AccentBlue,
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        readmeBtn.Activated += () => ShowInfoDialog(
            "Read Me",
            "All the contents used in this game are intended for educational and experimental purposes only.");
        subStack.AddChild(readmeBtn);

        var creditsBtn = new IgiMenuButton(theme, "Credits")
        {
            TextSize = 28f,
            Height = ShellSizes.MinTappable,
            Width = 402f,
            NormalColor = ShellBackButton.AccentBlue,
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        creditsBtn.Activated += () => ShowInfoDialog(
            "Credits",
            "Background and Controls - ProjectIGI Github project\nMade with Love, By R");
        subStack.AddChild(creditsBtn);

        menuStack.AddChild(subStack);
        frame.AddChild(menuStack);
        root.Add(frame, new Anchor(UiVec2.Zero, UiVec2.One, Thickness.Zero));

        // Dismissable info dialog: a dim scrim over the menu, then an opaque panel with a Close
        // button. Kept in the tree, collapsed, until a link opens it.
        _infoDialogScrim = new Panel { Background = Bgra32.FromRgba(0, 0, 0, 140), Visibility = Visibility.Collapsed };
        root.Add(_infoDialogScrim, Anchor.Fill);

        _infoDialog = new IgiBorderedBox
        {
            Width = 760f,
            Height = 400f,
            BackgroundColor = ShellBackButton.PanelFill,
            BorderColor = ShellBackButton.AccentBlue,
            StrokeWidth = 1.5f,
            Padding = new Thickness(36f, 28f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
            Visibility = Visibility.Collapsed,
        };
        var dialogStack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 20f,
        };
        _infoDialogTitle = new Label(theme.Heading, string.Empty, 28f, Bgra32.FromRgb(235, 242, 250));
        dialogStack.AddChild(_infoDialogTitle);
        _infoDialogText = new Label(theme.Body, string.Empty, 20f, Bgra32.FromRgb(180, 200, 225)) { Wrap = true };
        dialogStack.AddChild(_infoDialogText);
        _infoDialogClose = new IgiMenuButton(theme, "Close")
        {
            TextSize = 28f,
            Height = ShellSizes.MinTappable,
            Width = 260f,
            NormalColor = ShellBackButton.AccentBlue,
            HoverColor = Bgra32.FromRgb(228, 238, 252),
        };
        _infoDialogClose.Activated += HideInfoDialog;
        dialogStack.AddChild(_infoDialogClose);
        _infoDialog.AddChild(dialogStack);
        root.Add(_infoDialog, Anchor.Fill);

        return root;
    }

    /// <inheritdoc/>
    protected override bool HandleInput(UiNavigation nav, InputState input)
    {
        if (_infoDialogOpen)
        {
            // Back dismisses the dialog, not the page.
            if (nav.Back)
            {
                HideInfoDialog();
                return false;
            }

            if (input.Mouse.WasPressed(MouseButton.Left))
            {
                var pointer = new UiVec2(input.Mouse.X, input.Mouse.Y);
                if (_infoDialogClose is not null && _infoDialogClose.Bounds.Contains(pointer))
                {
                    // On the Close button: let it activate as usual.
                    return base.HandleInput(nav, input);
                }

                if (_infoDialog is null || !_infoDialog.Bounds.Contains(pointer))
                {
                    // Tap outside the dialog dismisses it.
                    HideInfoDialog();
                }

                // A tap on the dialog itself, or the dismiss above, swallows the press: nothing
                // under the dialog may activate while it is open.
                return false;
            }
        }
        else if (nav.Back)
        {
            // The root page: back quits, the same as the Quit button.
            Context.Host.Quit();
            return false;
        }

        return base.HandleInput(nav, input);
    }

    private void ShowInfoDialog(string title, string text)
    {
        if (_infoDialogTitle is not null)
        {
            _infoDialogTitle.Text = title;
        }

        if (_infoDialogText is not null)
        {
            _infoDialogText.Text = text;
        }

        if (_infoDialogScrim is not null)
        {
            _infoDialogScrim.Visibility = Visibility.Visible;
        }

        if (_infoDialog is not null)
        {
            _infoDialog.Visibility = Visibility.Visible;
        }

        _infoDialogOpen = true;
        if (_infoDialogClose is not null)
        {
            Focus?.Focus(_infoDialogClose);
        }
    }

    private void HideInfoDialog()
    {
        if (_infoDialogScrim is not null)
        {
            _infoDialogScrim.Visibility = Visibility.Collapsed;
        }

        if (_infoDialog is not null)
        {
            _infoDialog.Visibility = Visibility.Collapsed;
        }

        _infoDialogOpen = false;
    }

    /// <inheritdoc/>
    protected override void OnEnter()
    {
        // No heavy 3D showcase streaming to guarantee instant, responsive boot
    }
}
