using System.Runtime.InteropServices.JavaScript;
using System.Runtime.Versioning;
using ProjectIGI.Audio.Web;
using ProjectIGI.Composition;
using ProjectIGI.Core.Configuration;
using ProjectIGI.Core.Configuration.Presets;
using ProjectIGI.Core.Diagnostics;
using ProjectIGI.Core.Threading;
using ProjectIGI.Engine.Configuration;
using ProjectIGI.Engine.Titles;
using ProjectIGI.Engine.Vfs;
using ProjectIGI.Host;
using ProjectIGI.Host.Configuration;
using ProjectIGI.Platform;
using ProjectIGI.Platform.Web;
using ProjectIGI.Rendering;
using ProjectIGI.Rendering.Pipeline;
using ProjectIGI.Rendering.WebGpu;

namespace ProjectIGI.Web;

/// <summary>The browser's composition root over the fork's tree: what the page starts, and steps once a frame.</summary>
/// <remarks>
/// <para>
/// The desktop's root runs the game to the end in one call. A page cannot: the browser has to get its
/// thread back between frames to deliver input, present, and read files. So the page calls
/// <see cref="Boot"/> once, when the adapter is acquired and the picked files are in place, and then
/// <see cref="Step"/> from each animation frame until it says the game has finished.
/// </para>
/// <para>
/// The installation is read from <see cref="GameRoot"/>, where the page writes the picked files into the
/// runtime's in-memory file system -- so the host reads them by path, exactly as it reads a disk.
/// </para>
/// <para>
/// This is the fork's host, not upstream's: the game that boots here is the mobile build's code -- its
/// cutscene fixes, its save-load AI fix, its keyboard map, its retail menu -- over the same WebGPU canvas.
/// There is no multiplayer here: the fork has no Net tree, so there are no rooms, no sessions, no player
/// identity and no Discord Activity to wire. Single-player only, folder-pick only.
/// </para>
/// </remarks>
[SupportedOSPlatform("browser")]
public static partial class Program
{
    /// <summary>Where the page puts the installation.</summary>
    public const string GameRoot = "/game";

    private static GameHost? _game;
    private static BrowserPage? _page;
    private static bool _textEntryWanted;

    /// <summary>Nothing: the page boots the game once its files are in place.</summary>
    public static void Main()
    {
    }

    /// <summary>Gets the folder the player's own files are written to -- settings, profiles, saves -- which the page keeps.</summary>
    /// <returns>The folder, made if it wasn't there.</returns>
    [JSExport]
    public static string UserDirectory() => SettingsPaths.GetUserDirectory();

    /// <summary>Builds the game over the page's canvas and starts it.</summary>
    /// <param name="args">Command-line options, as the desktop takes them, from the page's address.</param>
    [JSExport]
    public static void Boot(string[] args)
    {
        if (_game is not null)
        {
            throw new InvalidOperationException("The game has already booted.");
        }

        // The browser's developer console, plus the in-game console once the game attaches it.
        LogRouter logger = new LogRouter().AddSink(new ConsoleSink());

        // The browser build is the original's picture: the preset is held on Vanilla whatever was saved.
        HostOptions options = HostOptions.Parse(args ?? []) with
        {
            LockedPreset = GraphicsPreset.Vanilla,
        };
        // The page says which game it put in place (-title, from its game switch); there is nothing to probe.
        IGameTitleRuntime runtime = TitleCatalog.Default;
        if (options.Title is { } requested)
        {
            runtime = TitleCatalog.TryResolve(requested, out IGameTitleRuntime? chosen)
                ? chosen
                : throw new ArgumentException($"'{requested}' is not a game this build runs. -title {TitleCatalog.KnownTitleIds}");
        }

        VirtualFileSystem fileSystem = new(logger);
        fileSystem.RegisterDevice(new LocalFileDevice(GameRoot));
        FileSystemConfig
            .LoadOrDefault(Path.Combine(GameRoot, FileSystemConfig.DefaultFileName), runtime.Layout)
            .ApplyTo(fileSystem);

        // Kept, not made inline: Step() polls the host's text-entry flags and drives the page through it.
        BrowserPage page = new();
        _page = page;
        WebPlatformHost platform = new(page);
        IGameWindow window = platform.CreateWindow(new WindowSettings(
            Title: "ProjectIGI",
            Width: 0,
            Height: 0,
            Mode: WindowMode.Windowed,
            CursorVisible: false,
            VSync: true));

        WebGpuRhiDevice rhi = WebGpuRhiDevice.CreateForWindow(
            new WebGpuWindowHandles(WebGpuWindowSystem.Canvas, 0, 0),
            window.Width,
            window.Height);

        GraphicsDevice device = new(rhi, new DisplayMode(window.Width, window.Height, 32, window.RefreshRate), logger: logger);
        logger.Information("Renderer", $"Drawing through the RHI over WebGPU on {rhi.AdapterName}.");

        // The adapter name is the only GPU identity that reaches the app layer, so the hardware tier is
        // classified from it here and handed to GameHost, which applies it on a first run only -- the same
        // as AndroidHost does. First run is the original's picture too, as on Android.
        HardwareTier tier = HardwareTiering.Classify(rhi.AdapterName, rhi.ApiName);
        logger.Information("Renderer", $"Hardware tier: {tier} ({rhi.AdapterName}): {HardwareTiering.Describe(tier)}.");

        // The composition root names the backends: the RHI over WebGPU above, and the Web Audio API here.
        // GameHost itself sees only the abstractions, exactly as it does on the desktop.
        _game = new GameHost(
            platform,
            window,
            device,
            new WebAudioDeviceFactory(new WebAudioPage()),
            InlineWorkScheduler.Instance,
            new WebLoadGate(),
            TitleCatalog.Rooted(runtime, GameRoot),
            runtime.Title,
            fileSystem,
            options with { FirstRunPreset = GraphicsPreset.Vanilla, VanillaMenu = true, HardwareTier = tier },
            GameRoot,
            logger);

        _game.Start();
    }

    /// <summary>Runs one frame.</summary>
    /// <returns><see langword="true"/> while the game goes on; <see langword="false"/> once it has stopped.</returns>
    [JSExport]
    public static bool Step()
    {
        if (_game is null)
        {
            return false;
        }

        if (!_game.Step())
        {
            _game.Stop();
            _game.Dispose();
            _game = null;
            _page = null;
            return false;
        }

        // Text entry is polled, not pushed: the fork's host exposes whether a text field is focused or the
        // keyboard was asked for, and the page is told when the answer changes. The fork's keyboard has no
        // line mode, so the page stays in character mode and typed text arrives char by char.
        bool wanted = _game.IsTextFieldFocused || _game.KeyboardRequested;
        if (wanted != _textEntryWanted)
        {
            _textEntryWanted = wanted;
            _page?.SetTextEntry(wanted);
        }

        return true;
    }
}
