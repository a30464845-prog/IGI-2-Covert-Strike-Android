using ProjectIGI.Core.Graphics;
using ProjectIGI.Input;
using ProjectIGI.UI;
using ProjectIGI.UI.Focus;
using ProjectIGI.UI.Layout;
using ProjectIGI.UI.Widgets;

namespace ProjectIGI.Frontend.Screens;

/// <summary>
/// The 48 dp floor, in the shell's own units: at the 1080p-high reference the shell scale is 1.2, so
/// one design unit is 1.2 physical pixels, and at a ~400 dpi density one dp is ~2.625 pixels — 48 dp
/// is ~126 pixels, ~104 design units. Every shell screen shares this scale context (1920×1080
/// reference, height-priority match, <c>GlobalUiScale</c> 1.2), so the one constant holds everywhere.
/// </summary>
public static class ShellSizes
{
    /// <summary>The smallest height or width a tappable control may be, in design units.</summary>
    public const float MinTappable = 104f;

    /// <summary>The standard width of the top-left back control, in design units.</summary>
    public const float BackButtonWidth = 260f;
}

/// <summary>
/// The drag-to-scroll gesture the shell's lists share: a press inside a scroll view starts a possible
/// drag, moving past 10 pixels scrolls the list, and releasing without moving activates the row under
/// the pointer instead. One copy, used by the campaign and load-game lists; the settings screen keeps
/// its own identical copy for now (its file belongs to the Configuration remake) and should switch to
/// this helper when that work lands.
/// </summary>
public sealed class DragScrollHelper
{
    private UiVec2? _touchDragStart;
    private float _touchDragStartOffset;
    private bool _isDragging;
    private Control? _pendingTapTarget;

    /// <summary>Routes a frame of pointer input to a scroll view's drag gesture.</summary>
    /// <param name="scroll">The list's viewport, or <see langword="null"/> when the screen has none.</param>
    /// <param name="focus">The screen's focus manager, for the control under the pointer.</param>
    /// <param name="input">The frame's raw input.</param>
    /// <returns>
    /// <see langword="true"/> when the gesture took the frame and the screen should handle nothing
    /// else for it; <see langword="false"/> when the press was outside the list or on its scrollbar,
    /// and the screen should carry on as usual.
    /// </returns>
    public bool HandleInput(ScrollView? scroll, FocusManager? focus, InputState input)
    {
        ArgumentNullException.ThrowIfNull(input);
        if (scroll is null)
        {
            return false;
        }

        var pointer = new UiVec2(input.Mouse.X, input.Mouse.Y);
        bool insideScroll = scroll.Bounds.Contains(pointer);

        if (input.Mouse.WasPressed(MouseButton.Left))
        {
            if (insideScroll && !scroll.IsOverScrollbar(pointer))
            {
                _touchDragStart = pointer;
                _touchDragStartOffset = scroll.ScrollOffset;
                _isDragging = false;
                _pendingTapTarget = focus?.FocusAt(pointer) as Control;
                return true;
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
                scroll.ScrollOffset = _touchDragStartOffset - dy;
                return true;
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
                return true;
            }
        }

        return false;
    }
}

/// <summary>
/// The one back control every shell screen carries, top-left at the 48 dp floor: the same label, the
/// same size, the same place, whatever the screen underneath does with "back".
/// </summary>
public static class ShellBackButton
{
    /// <summary>The back control for a screen laid out on a canvas: a menu button, top-left.</summary>
    /// <param name="theme">The theme.</param>
    /// <param name="onBack">What back means on this screen.</param>
    /// <returns>The button, sized and aligned for the canvas's top-left corner.</returns>
    public static IgiMenuButton MenuBack(UiTheme theme, Action onBack)
    {
        ArgumentNullException.ThrowIfNull(theme);
        ArgumentNullException.ThrowIfNull(onBack);
        var back = new IgiMenuButton(theme, "< Back")
        {
            TextSize = 28f,
            Height = ShellSizes.MinTappable,
            Width = ShellSizes.BackButtonWidth,
            HorizontalAlignment = HorizontalAlignment.Left,
            VerticalAlignment = VerticalAlignment.Top,
        };
        back.Activated += onBack;
        return back;
    }

    /// <summary>The back control for a screen laid out on a grid: an outlined button, top-left.</summary>
    /// <param name="theme">The theme.</param>
    /// <param name="onBack">What back means on this screen.</param>
    /// <returns>The button, sized for the grid's top row.</returns>
    public static Button PageBack(UiTheme theme, Action onBack)
    {
        ArgumentNullException.ThrowIfNull(theme);
        ArgumentNullException.ThrowIfNull(onBack);
        var back = new Button(theme, "< Back")
        {
            Accent = ButtonAccent.Ghost,
            TextSize = 20f,
            Height = ShellSizes.MinTappable,
            Padding = new Thickness(28f, 12f),
            HorizontalAlignment = HorizontalAlignment.Left,
            VerticalAlignment = VerticalAlignment.Top,
        };
        back.Activated += _ => onBack();
        return back;
    }

    /// <summary>The opaque dark panel fill every remade shell surface uses: <c>#08101E</c>.</summary>
    public static Bgra32 PanelFill => Bgra32.FromRgb(8, 16, 30);

    /// <summary>The one accent blue, for panel hairlines: <c>#50A0FF</c>.</summary>
    public static Bgra32 AccentBlue => Bgra32.FromRgb(80, 160, 255);
}
