using ProjectIGI.Input;
using ProjectIGI.Rendering;

namespace ProjectIGI.Platform.Web;

/// <summary>
/// The game's window in a browser: a canvas, and the input the page hands it each frame.
/// </summary>
/// <remarks>
/// <para>
/// The page owns everything a desktop window would: its size is the canvas's, laid out by the page; its
/// input is delivered to the page's handlers between frames and queued there; the pointer lock and
/// fullscreen are the browser's to grant. So this window reads a queue rather than dispatching events,
/// and asks rather than sets.
/// </para>
/// <para>
/// <b>A lost pointer lock is an Escape.</b> Escape is how a browser takes the lock back, and it keeps
/// the key to itself when it does. A game that asked for the lock has lost it in the middle of play, and
/// the one thing a player pressing Escape then expects is the pause menu -- so a lock lost while the game
/// still wants it is handed on as that key going down. The page then says when it comes up: at once for a tap, and
/// for as long as the key is held otherwise, which is what lets a cutscene be skipped by holding it.
/// </para>
/// <para>
/// <b>Every press lasts a frame.</b> The page queues events for as long as a frame takes, and a quick click
/// or tap can go down and up inside one: applied in order it would never be seen down at all. A release
/// that arrives in the frame its press did is held until the next.
/// </para>
/// <para>
/// A port of upstream's window onto the fork's tree, so it answers the fork's <see cref="IGameWindow"/>.
/// What that changes: gyro arrives through <see cref="TakeGyroMotion"/>, as on Android — the fork has no
/// <c>Input.Motion</c>, and the host drains the window's accumulated angle deltas every pass, applying
/// them only when the profile enables gyro — so the window arms the page's reporting once, at
/// construction, and the motion is drained and discarded where the setting is off. Typed text arrives
/// character by character: the fork's keyboard has no line mode (<c>ReplaceLine</c>), so the page is
/// never put into it and <c>line</c> events are ignored, and the page's text entry is driven by the app
/// polling the host's text-field flags rather than by this window. There is no pixel density or safe
/// insets here either — the fork's interface has neither — and a resize is taken as the page lays it
/// out, never forced sideways the way Android forces landscape. A canvas is never destroyed and
/// recreated, so the surface-recreated queue the interface's <c>PumpSurfaceEvents</c> drains does not
/// exist here; the interface's default (no-op) stands.
/// </para>
/// </remarks>
public sealed class WebGameWindow : IGameWindow
{
    private readonly IBrowserPage _page;
    private readonly List<KeyCode> _releaseNextFrame = [];
    private readonly List<MouseButton> _releaseButtonNextFrame = [];
    private readonly HashSet<KeyCode> _pressedThisFrame = [];
    private readonly HashSet<MouseButton> _buttonsPressedThisFrame = [];
    private string _title;
    private string _clipboard = string.Empty;
    private (int Width, int Height) _size;
    private WindowMode _mode;
    private bool _cursorVisible;
    private bool _cursorLocked;
    // Gyroscope look motion accumulated this frame, in radians (yaw, pitch).
    private float _gyroYaw;
    private float _gyroPitch;
    // 0 = 540p ultra, 1 = 720p performance, 2 = 900p balanced, 3 = native. Stored here, but the
    // resolution itself lives in the renderer's r_scale console variable: setting a tier sets
    // r_scale to that tier's height over this window's height, and r_scale is what the frame
    // actually renders at (RenderResolutionPolicy) and what survives a restart (archived CVar).
    private int _renderScaleMode = 1;
    private bool _disposed;

    /// <summary>Initialises a new instance of the <see cref="WebGameWindow"/> class.</summary>
    /// <param name="page">The page it runs in.</param>
    /// <param name="settings">
    /// What the game asked for. The title and the cursor are applied; the size is not, because the page
    /// lays the canvas out, and a fullscreen mode is only asked for when a click allows it.
    /// </param>
    public WebGameWindow(IBrowserPage page, in WindowSettings settings)
    {
        ArgumentNullException.ThrowIfNull(page);

        _page = page;
        _title = settings.Title;
        _cursorVisible = settings.CursorVisible;
        _size = page.CanvasSize;
        IsFocused = page.HasFocus;

        _page.SetTitle(_title);
        _page.SetPointer(_cursorVisible, _cursorLocked);
        // The fork streams gyro always and applies it only when the profile enables it, so the page
        // reports motion from the start; on a phone that asks the player's leave on the next tap.
        _page.SetGyro(true);
    }

    /// <inheritdoc/>
    public event EventHandler<WindowResizedEventArgs>? Resized;

    /// <inheritdoc/>
    public event EventHandler? CloseRequested;

    /// <inheritdoc/>
    public string Title
    {
        get => _title;
        set
        {
            _title = value ?? string.Empty;
            _page.SetTitle(_title);
        }
    }

    /// <inheritdoc/>
    public int Width => Math.Max(1, _size.Width);

    /// <inheritdoc/>
    public int Height => Math.Max(1, _size.Height);

    /// <inheritdoc/>
    /// <remarks>Fullscreen is asked of the page, which grants it only during a click.</remarks>
    public WindowMode Mode
    {
        get => _mode;
        set
        {
            if (_mode == value)
            {
                return;
            }

            _mode = value;
            _page.RequestFullscreen(value != WindowMode.Windowed);
        }
    }

    /// <inheritdoc/>
    /// <remarks>
    /// Nothing tells a page its display's rate. The browser paces frames to it regardless, so this is the
    /// common rate, reported and not relied on.
    /// </remarks>
    public int RefreshRate => 60;

    /// <inheritdoc/>
    public bool CursorVisible
    {
        get => _cursorVisible;
        set
        {
            if (_cursorVisible != value)
            {
                _cursorVisible = value;
                _page.SetPointer(_cursorVisible, _cursorLocked);
            }
        }
    }

    /// <inheritdoc/>
    public bool CursorLocked
    {
        get => _cursorLocked;
        set
        {
            if (_cursorLocked != value)
            {
                _cursorLocked = value;
                _page.SetPointer(_cursorVisible, _cursorLocked);
            }
        }
    }

    /// <summary>Gets whether the browser has granted the pointer lock the game asked for.</summary>
    public bool PointerLockGranted { get; private set; }

    /// <inheritdoc/>
    /// <remarks>
    /// A page may write to the clipboard but not read it without asking the person, so what this reads is
    /// what the game last wrote.
    /// </remarks>
    public string ClipboardText
    {
        get => _clipboard;
        set
        {
            _clipboard = value ?? string.Empty;
            _page.WriteClipboard(_clipboard);
        }
    }

    /// <inheritdoc/>
    public bool IsFocused { get; private set; }

    /// <inheritdoc/>
    public bool IsClosing { get; private set; }

    /// <inheritdoc/>
    public InputState Input { get; } = new();

    /// <inheritdoc/>
    /// <remarks>The one mode there is: the canvas at the size the page shows it.</remarks>
    public IReadOnlyList<(int Width, int Height, int RefreshRate)> GetDisplayModes() => [(Width, Height, RefreshRate)];

    /// <inheritdoc/>
    /// <remarks>Ignored: the page lays the canvas out, and a resize arrives from there.</remarks>
    public void Resize(int width, int height)
    {
    }

    /// <summary>Gets or sets the render scale tier shown in Settings.</summary>
    public int RenderScaleMode
    {
        get => _renderScaleMode;
        set
        {
            _renderScaleMode = Math.Clamp(value, 0, 3);
            float height = _size.Height > 0 ? _size.Height : 1080f;
            ReconstructionCVars.RenderScale.Value = _renderScaleMode switch
            {
                0 => Math.Clamp(540f / height, 0.25f, 1f),
                1 => Math.Clamp(720f / height, 0.25f, 1f),
                2 => Math.Clamp(900f / height, 0.25f, 1f),
                _ => 1f,
            };
        }
    }

    /// <summary>Sets the tier that matches the render scale already in force (loaded from settings), so the menu shows the tier actually being rendered.</summary>
    public void SyncRenderScaleMode()
    {
        float height = _size.Height > 0 ? _size.Height : 1080f;
        float scale = ReconstructionCVars.RenderScale.Value;
        float tier0 = Math.Clamp(540f / height, 0.25f, 1f);
        float tier1 = Math.Clamp(720f / height, 0.25f, 1f);
        float tier2 = Math.Clamp(900f / height, 0.25f, 1f);
        float d0 = Math.Abs(scale - tier0);
        float d1 = Math.Abs(scale - tier1);
        float d2 = Math.Abs(scale - tier2);
        float d3 = Math.Abs(scale - 1f);
        _renderScaleMode = d0 <= d1 && d0 <= d2 && d0 <= d3 ? 0 : d1 <= d2 && d1 <= d3 ? 1 : d2 <= d3 ? 2 : 3;
    }

    /// <summary>Gets the gyroscope look motion accumulated this frame, in radians (yaw, pitch), and clears it.</summary>
    public (float Yaw, float Pitch) TakeGyroMotion()
    {
        (float Yaw, float Pitch) motion = (_gyroYaw, _gyroPitch);
        _gyroYaw = 0f;
        _gyroPitch = 0f;
        return motion;
    }

    /// <inheritdoc/>
    /// <remarks>The canvas is on the page already.</remarks>
    public void Show() => ObjectDisposedException.ThrowIf(_disposed, this);

    /// <inheritdoc/>
    public void PumpEvents()
    {
        ObjectDisposedException.ThrowIf(_disposed, this);

        // Shadow first, then apply: the events this call delivers belong to the frame about to run.
        Input.BeginFrame();

        foreach (KeyCode key in _releaseNextFrame)
        {
            Input.Keyboard.SetKey(key, down: false);
        }

        foreach (MouseButton button in _releaseButtonNextFrame)
        {
            Input.Mouse.SetButton(button, down: false);
        }

        _releaseNextFrame.Clear();
        _releaseButtonNextFrame.Clear();
        _pressedThisFrame.Clear();
        _buttonsPressedThisFrame.Clear();

        foreach (string line in _page.TakeEvents())
        {
            Apply(WebInputEvent.Parse(line));
        }
    }

    /// <inheritdoc/>
    /// <remarks>A page cannot close its own tab; the game is told it is closing, and stops.</remarks>
    public void Close()
    {
        if (!_disposed && !IsClosing)
        {
            IsClosing = true;
            CloseRequested?.Invoke(this, EventArgs.Empty);
        }
    }

    /// <inheritdoc/>
    public void Dispose()
    {
        if (_disposed)
        {
            return;
        }

        _disposed = true;
        _page.SetPointer(visible: true, locked: false);
        _page.SetGyro(false);
    }

    private void Apply(in WebInputEvent input)
    {
        switch (input.Kind)
        {
            case WebInputEventKind.Key:
                KeyCode key = WebKeyMap.Translate(input.Code);
                if (key == KeyCode.None)
                {
                    break;
                }

                if (input.Down)
                {
                    _pressedThisFrame.Add(key);
                    Input.Keyboard.SetKey(key, down: true);
                }
                else if (_pressedThisFrame.Contains(key))
                {
                    _releaseNextFrame.Add(key);
                }
                else
                {
                    Input.Keyboard.SetKey(key, down: false);
                }

                break;

            case WebInputEventKind.Line:
                // The fork's keyboard has no line mode, and the page is never put into it: nothing
                // to take a line with, so one is ignored rather than fed twice over as characters.
                break;

            case WebInputEventKind.Inset:
                // The fork's window has no text-entry inset to report; the keyboard covering the
                // bottom of the canvas is the page's business, not the game's.
                break;

            case WebInputEventKind.Character:
                foreach (char character in input.Code)
                {
                    Input.Keyboard.EnqueueCharacter(character);
                }

                break;

            case WebInputEventKind.Move:
                Input.Mouse.AddMotion(input.X, input.Y);
                Input.Mouse.SetPosition(input.Z, input.W);
                break;

            case WebInputEventKind.Button:
                if (Button((int)input.X) is not { } button)
                {
                    break;
                }

                if (input.Down)
                {
                    _buttonsPressedThisFrame.Add(button);
                    Input.Mouse.SetButton(button, down: true);
                }
                else if (_buttonsPressedThisFrame.Contains(button))
                {
                    _releaseButtonNextFrame.Add(button);
                }
                else
                {
                    Input.Mouse.SetButton(button, down: false);
                }

                break;

            case WebInputEventKind.Wheel:
                Input.Mouse.AddWheel(input.X);
                break;

            case WebInputEventKind.Resize:
                (int Width, int Height) size = ((int)input.X, (int)input.Y);
                if (size != _size && size.Width > 0 && size.Height > 0)
                {
                    _size = size;
                    Resized?.Invoke(this, new WindowResizedEventArgs(size.Width, size.Height));
                }

                break;

            case WebInputEventKind.Focus:
                IsFocused = input.Down;
                if (!input.Down)
                {
                    // As the desktop: keys still held when the page lost the keyboard never report
                    // their release, and would stay latched down until pressed again.
                    Input.Keyboard.Release();
                    Input.Mouse.Reset();
                    Input.Touch.Release();
                }

                break;

            case WebInputEventKind.PointerLock:
                bool lost = PointerLockGranted && !input.Down;
                PointerLockGranted = input.Down;
                if (lost && _cursorLocked)
                {
                    // Down from here; the page says when it comes up (platform.js, escapeTaken), as it does for any key --
                    // in this same frame for a tap, which the frame's press then outlasts like any other.
                    _pressedThisFrame.Add(KeyCode.Escape);
                    Input.Keyboard.SetKey(KeyCode.Escape, down: true);
                }

                break;

            case WebInputEventKind.Close:
                Close();
                break;

            case WebInputEventKind.Touch:
                int finger = (int)input.Z;
                switch (input.Code)
                {
                    case "down":
                        Input.Touch.Down(finger, input.X, input.Y);
                        break;
                    case "move":
                        Input.Touch.Move(finger, input.X, input.Y);
                        break;
                    default:
                        Input.Touch.Up(finger, input.X, input.Y);
                        break;
                }

                break;

            case WebInputEventKind.Gyro:
                // The fork has no Input.Motion: the deltas accumulate here, and the host drains
                // them through TakeGyroMotion, applying them only when the profile enables gyro.
                _gyroYaw += input.X;
                _gyroPitch += input.Y;
                break;
        }
    }

    /// <summary>A DOM mouse button number as the engine's button.</summary>
    private static MouseButton? Button(int number) => number switch
    {
        0 => MouseButton.Left,
        1 => MouseButton.Middle,
        2 => MouseButton.Right,
        3 => MouseButton.Extra1,
        4 => MouseButton.Extra2,
        _ => null,
    };
}
