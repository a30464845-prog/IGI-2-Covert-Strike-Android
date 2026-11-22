using ProjectIGI.Core.Graphics;
using ProjectIGI.Input;
using ProjectIGI.UI;
using ProjectIGI.UI.Drawing;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// Project I.G.I. 2 "Paused" menu, restyled after the pause concept
/// (~/workspace/user/media_library/image/image-d2480c1c.png): "GAME PAUSED" in
/// white caps above a dark teal translucent panel with cut corners, and the
/// menu rows as lighter blue-grey angled bars with centred, letterspaced caps.
/// DESIGN ONLY — the port's own items are kept exactly as they were:
/// Resume, Restart Mission, Customize Controls, Configuration, Abort Mission,
/// in that order, with the same actions. Nothing from the concept's item list
/// was copied (no Objectives, Save, Free Camera, or Exit rows).
/// Rows are 104 units tall (48 dp at the 1080p-high reference); the visible back
/// control top-left resumes, exactly like Back / Escape.
/// </summary>
/// <remarks>
/// No CONSOLE row: the host plumbing that used to open the console from here
/// (IShellHost.OpenConsole, added by PR #86) is not in live main, so there is no
/// call a pause row could make — restoring it needs the host side back first.
/// All new drawing helpers live in this file (PausePanel, PauseButton,
/// PauseTitle, PauseGap). Shared files (UiPainter, UiTheme, IgiWidgets) are
/// untouched, so this restyle cannot collide with the options-screen restyle.
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
        // reference), restyled to the concept palette: a small cut-corner
        // teal chip with an angled bar. Back = Resume, same as the
        // Back key / Escape handled below.
        var backFrame = new PausePanel
        {
            Width = 220f,
            Height = 104f,
            Cut = 16f,
            HorizontalAlignment = HorizontalAlignment.Left,
            VerticalAlignment = VerticalAlignment.Top,
        };
        var backBtn = new PauseButton(theme, "< BACK")
        {
            TextSize = 30f,
            Height = 88f,
            Width = 200f,
        };
        backBtn.Activated += () => Context.Host.ResumeMission();
        backFrame.AddChild(backBtn);
        root.Add(backFrame, new Anchor(UiVec2.Zero, new UiVec2(0.2f, 0.15f), new Thickness(16f, 16f, 0f, 0f)));

        // Centred column: the "GAME PAUSED" title above the panel, like the
        // concept — the title sits outside the panel, not in a header band.
        var column = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 28f,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var title = new PauseTitle(theme)
        {
            Width = 1020f,
            Height = 76f,
            HorizontalAlignment = HorizontalAlignment.Center,
        };
        column.AddChild(title);

        // Central panel: dark teal, translucent so the blurred mission shows
        // faintly through it, all four corners cut at 45°. 1020 units is ~53%
        // of the 1920-wide reference, like the concept's ~55%-wide panel.
        var frame = new PausePanel
        {
            Width = 1020f,
            Height = 756f,
            Cut = 40f,
            Padding = new Thickness(0f, 48f, 0f, 48f),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        var menuStack = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 22f,
            Width = 900f,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
        };

        // Rows are 104 units tall: 48 dp at the 1080p-high reference (Scale 1.2).
        // Same five items, same order, same actions as before the restyle.
        var resumeBtn = new PauseButton(theme, "RESUME") { TextSize = 34f, Height = 104f, Width = 900f };
        resumeBtn.Activated += () => Context.Host.ResumeMission();
        menuStack.AddChild(resumeBtn);

        var restartBtn = new PauseButton(theme, "RESTART MISSION") { TextSize = 34f, Height = 104f, Width = 900f };
        restartBtn.Activated += () => Context.Host.RestartMission();
        menuStack.AddChild(restartBtn);

        var customBtn = new PauseButton(theme, "CUSTOMIZE CONTROLS") { TextSize = 34f, Height = 104f, Width = 900f };
        customBtn.Activated += () => Context.Host.CustomizeTouchControls();
        menuStack.AddChild(customBtn);

        var configBtn = new PauseButton(theme, "CONFIGURATION") { TextSize = 34f, Height = 104f, Width = 900f };
        configBtn.Activated += () => Context.Stack.Reset(new SettingsScreen(Context));
        menuStack.AddChild(configBtn);

        // The concept groups its rows with a larger gap before the last group
        // at the panel bottom. The port has five rows, so the gap sits before
        // the last one — Abort Mission, the destructive/exit action, like the
        // concept's bottom group. Spacing only; no item moved or renamed.
        menuStack.AddChild(new PauseGap { Height = 30f });

        var abortBtn = new PauseButton(theme, "ABORT MISSION")
        {
            TextSize = 34f,
            Height = 104f,
            Width = 900f,
            NormalColor = Bgra32.FromRgb(255, 95, 80),
            HoverColor = Bgra32.FromRgb(255, 180, 170),
        };
        abortBtn.Activated += () => Context.Host.AbandonMission();
        menuStack.AddChild(abortBtn);

        frame.AddChild(menuStack);
        column.AddChild(frame);
        root.Add(column, Anchor.Fill);

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

    /// <summary>
    /// The concept's panel: a dark teal translucent fill with every corner cut
    /// at 45°, a darker outer outline, and a lighter inner bevel hairline.
    /// Drawn with the shared <see cref="UiPainter"/> cut-rect primitives; the
    /// panel itself is local to this screen.
    /// </summary>
    private sealed class PausePanel : Panel
    {
        /// <summary>Gets or sets the 45° cut length at each corner, in design units.</summary>
        public float Cut { get; set; } = 40f;

        /// <summary>Gets or sets the translucent dark teal fill.</summary>
        public Bgra32 PanelColor { get; set; } = Bgra32.FromRgba(10, 46, 64, 210);

        /// <summary>Gets or sets the darker outer outline.</summary>
        public Bgra32 BorderColor { get; set; } = Bgra32.FromRgb(8, 30, 44);

        /// <summary>Gets or sets the lighter inner bevel hairline.</summary>
        public Bgra32 BevelColor { get; set; } = Bgra32.FromRgba(86, 160, 190, 140);

        /// <inheritdoc/>
        protected override void OnDraw(UiPainter painter)
        {
            UiRect b = Bounds;
            if (b.IsEmpty)
            {
                return;
            }

            float cut = painter.Context.Px(Cut);
            painter.FillCutRect(b, cut, UiCorners.All, PanelColor);
            painter.StrokeCutRect(b, cut, UiCorners.All, painter.Context.Px(2f), BorderColor);

            float inset = painter.Context.Px(6f);
            var inner = new UiRect(b.X + inset, b.Y + inset, b.Width - (inset * 2f), b.Height - (inset * 2f));
            painter.StrokeCutRect(inner, MathF.Max(0f, cut - inset), UiCorners.All, painter.Context.Px(1f), BevelColor);

            base.OnDraw(painter);
        }
    }

    /// <summary>
    /// The concept's button bar: a lighter blue-grey horizontal bar with angled
    /// (cut) ends, a top highlight and bottom shade, and a centred white caps
    /// label with letterspacing. Behaviour is exactly
    /// <see cref="IgiMenuButton"/>'s — same <c>Activated</c> event, same focus /
    /// hover / press states, same hit area (<c>PointerBounds</c> inherited) —
    /// only the drawing changes. Text stays <see cref="IgiMenuButton.NormalColor"/> /
    /// <see cref="IgiMenuButton.HoverColor"/>, so Abort Mission keeps its red.
    /// The label is set in the theme's regular body face, not the condensed
    /// heading face: the narrow condensed caps were hard to read at phone
    /// sizes (Ray 2026-11-22), and the body face is already loaded, so this
    /// costs no new font.
    /// </summary>
    private sealed class PauseButton : IgiMenuButton
    {
        private readonly UiTheme _theme;

        /// <summary>Initializes a new instance of the <see cref="PauseButton"/> class.</summary>
        /// <param name="theme">The UI theme.</param>
        /// <param name="text">The button text.</param>
        public PauseButton(UiTheme theme, string text)
            : base(theme, text)
        {
            _theme = theme;
            NormalColor = Bgra32.White;
            HoverColor = Bgra32.White;
        }

        /// <inheritdoc/>
        protected override void OnDraw(UiPainter painter)
        {
            UiRect b = Bounds;
            if (b.IsEmpty)
            {
                return;
            }

            bool isHovered = IsPointerOver || Visual.Focus > 0.05f || Visual.Press > 0.05f;
            bool isPressed = Visual.Press > 0.05f;

            // Angled bar: every corner cut at 45°, like the concept's chevron ends.
            float cut = painter.Context.Px(14f);
            Bgra32 fill = isPressed
                ? Bgra32.FromRgba(70, 102, 134, 255)
                : isHovered
                    ? Bgra32.FromRgba(122, 164, 198, 255)
                    : Bgra32.FromRgba(92, 128, 162, 235);
            painter.FillCutRect(b, cut, UiCorners.All, fill);
            painter.StrokeCutRect(
                b,
                cut,
                UiCorners.All,
                painter.Context.Px(isHovered ? 2f : 1.5f),
                isHovered ? Bgra32.FromRgb(150, 205, 235) : Bgra32.FromRgb(38, 84, 112));

            // Top highlight and bottom shade give the flat bar its depth.
            float edge = painter.Context.Px(4f);
            float strip = painter.Context.Px(2f);
            painter.FillRect(
                new UiRect(b.X + cut, b.Y + edge, b.Width - (cut * 2f), strip),
                Bgra32.FromRgba(255, 255, 255, 26));
            painter.FillRect(
                new UiRect(b.X + cut, b.Bottom - edge - strip, b.Width - (cut * 2f), strip),
                Bgra32.FromRgba(0, 0, 0, 48));

            // Centred caps label with letterspacing, like the concept, in the
            // regular body face for readability (see the class note above).
            float size = painter.Context.Px(TextSize);
            float tracking = size * 0.10f;
            float width = UiPainter.MeasureTracked(_theme.Body, Text, size, tracking) - tracking;
            float tx = b.X + ((b.Width - width) * 0.5f);
            float ty = b.Y + ((b.Height - size) * 0.5f);
            Bgra32 color = isHovered ? HoverColor : NormalColor;
            painter.DrawTextTracked(_theme.Body, Text, new UiVec2(tx, ty + painter.Context.Px(2f)), size, Bgra32.FromRgba(0, 0, 0, 170), tracking);
            painter.DrawTextTracked(_theme.Body, Text, new UiVec2(tx, ty), size, color, tracking);
        }
    }

    /// <summary>
    /// The concept's title: "GAME PAUSED" in white caps, centred, letterspaced,
    /// drawn above the panel instead of inside a header band. Set in the
    /// regular body face, not the condensed display face, for readability —
    /// same reason as the button labels above.
    /// </summary>
    private sealed class PauseTitle : UiElement
    {
        private readonly UiTheme _theme;

        /// <summary>Initializes a new instance of the <see cref="PauseTitle"/> class.</summary>
        /// <param name="theme">The UI theme.</param>
        public PauseTitle(UiTheme theme)
        {
            _theme = theme;
        }

        /// <summary>Gets or sets the title text size in design units.</summary>
        public float TextSize { get; set; } = 46f;

        /// <inheritdoc/>
        protected override void OnDraw(UiPainter painter)
        {
            UiRect b = Bounds;
            if (b.IsEmpty)
            {
                return;
            }

            const string text = "GAME PAUSED";
            float size = painter.Context.Px(TextSize);
            float tracking = size * 0.12f;
            float width = UiPainter.MeasureTracked(_theme.Body, text, size, tracking) - tracking;
            float tx = b.X + ((b.Width - width) * 0.5f);
            float ty = b.Y + ((b.Height - size) * 0.5f);
            painter.DrawTextTracked(_theme.Body, text, new UiVec2(tx, ty + painter.Context.Px(2f)), size, Bgra32.FromRgba(0, 0, 0, 170), tracking);
            painter.DrawTextTracked(_theme.Body, text, new UiVec2(tx, ty), size, Bgra32.White, tracking);
        }
    }

    /// <summary>A fixed-height blank gap between menu rows (design only).</summary>
    private sealed class PauseGap : UiElement
    {
    }
}
