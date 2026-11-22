using ProjectIGI.Core.Configuration;
using ProjectIGI.Core.Graphics;
using ProjectIGI.Frontend.Screens;
using ProjectIGI.Game.Player;
using ProjectIGI.Host.Configuration;
using ProjectIGI.Input;
using ProjectIGI.Presentation.Text;
using ProjectIGI.Rendering;
using ProjectIGI.UI;
using ProjectIGI.UI.Layout;

namespace ProjectIGI.Host;

public sealed partial class GameHost
{
    private bool _cheatsModalOpen;

    // The main-menu strip: one labelled 48 dp row per entry, top-right, in place of
    // the old tiny icon column. 48 dp is 56 units here: the overlay scale is
    // clamp(height / 480, 1, 3), so at 1080p-high one unit is 2.25 px and
    // 48 dp is 126 px. A row is tappable across its whole rect — no invisible
    // hit-area extension is needed any more.
    private enum MenuStripAction
    {
        Cheats,
        Benchmark,
        Settings,
    }

    private readonly record struct MenuStripRow(MenuStripAction Action, UiRect Rect);

    private static MenuStripRow[] MenuStripRows(float width, float scale)
    {
        // 160 units wide: glyph + label with room to spare, and narrow enough to
        // stay mostly in the margin right of the retail menu (the old 28-unit
        // icons lived there entirely; a labelled row cannot, so the strip's
        // left edge may sit over menu art — see the screenshot ask in the report).
        const float rowW = 160f;
        const float rowH = 56f;
        const float gap = 8f;
        const float margin = 12f;
        MenuStripAction[] actions =
        [
            MenuStripAction.Cheats,
            MenuStripAction.Benchmark,
            MenuStripAction.Settings,
        ];
        var rows = new MenuStripRow[actions.Length];
        for (int i = 0; i < actions.Length; i++)
        {
            float x = width - (rowW * scale) - (margin * scale);
            float y = (margin * scale) + (i * (rowH + gap) * scale);
            rows[i] = new MenuStripRow(actions[i], new UiRect(x, y, rowW * scale, rowH * scale));
        }

        return rows;
    }

    private static string MenuStripLabel(MenuStripAction action) => action switch
    {
        MenuStripAction.Cheats => "CHEATS",
        MenuStripAction.Benchmark => "BENCHMARK",
        MenuStripAction.Settings => "SETTINGS",
        _ => string.Empty,
    };

    private void UpdateCheatsOverlay(FrameLoopState state)
    {
        // Active strictly on the main menu landing screen
        bool isMainMenu = _session.Mission == null && !_menuFlow.PauseMenu && state.Shell?.Stack.Top is MainMenuScreen;
        if (!isMainMenu)
        {
            _cheatsModalOpen = false;
            return;
        }

        // While a benchmark is running the menu is hidden and the strip is not drawn; the modal
        // cannot open under the drone view. The first-run prompt is the same: its own buttons
        // own the taps until it is answered.
        if (BenchmarkRunning || _benchmarkPromptUp)
        {
            _cheatsModalOpen = false;
            return;
        }

        float width = SafeWindowWidth;
        float height = SafeWindowHeight;
        float scale = Math.Clamp(height / 480f, 1f, 3f);

        InputState input = _window.Input;
        bool click = false;
        float clickX = 0f, clickY = 0f;

        // Detect touch tap
        if (input.Touch.InUse)
        {
            foreach (var point in input.Touch.Points)
            {
                if (point.Began)
                {
                    click = true;
                    clickX = point.X;
                    clickY = point.Y;
                    break;
                }
            }
        }

        // Detect mouse click
        if (!click && input.Mouse.WasPressed(MouseButton.Left))
        {
            click = true;
            clickX = input.Mouse.X;
            clickY = input.Mouse.Y;
        }

        if (!_cheatsModalOpen)
        {
            if (!click)
            {
                return;
            }

            // The labelled strip: each row is a full 48 dp target, so the row rect
            // itself is the hit area.
            foreach (MenuStripRow row in MenuStripRows(width, scale))
            {
                if (!row.Rect.Contains(clickX, clickY))
                {
                    continue;
                }

                switch (row.Action)
                {
                    case MenuStripAction.Cheats:
                        _cheatsModalOpen = true;
                        break;

                    // Benchmark has its own entry point now, out of the cheats modal:
                    // this row starts the run over the Weather Station. Inert while a
                    // run is already going (the strip is hidden during one anyway).
                    case MenuStripAction.Benchmark:
                        if (!BenchmarkRunning)
                        {
                            StartBenchmark(state, manual: true);
                        }

                        break;

                    // Settings: taps open the pause menu's configuration screen over
                    // the retail menu, so settings can be changed before a mission
                    // starts.
                    case MenuStripAction.Settings:
                        if (state.Shell is { } shell)
                        {
                            // Menu mode is what lets the shell update and draw over the retail
                            // menu; the retail menu's own tasks see idle input while it is set
                            // (UpdateShell marks the frame captured), so the menu underneath
                            // cannot react to taps on the settings.
                            shell.OpenSettingsFromMainMenu();
                            _menuFlow.MenuMode = true;
                        }

                        break;
                }

                // Suppress click so the menu beneath does not click Play/Exit
                input.Mouse.SetButton(MouseButton.Left, down: false);
                return;
            }

            return;
        }

        // When cheats modal is open, always suppress underlying clicks
        input.Mouse.SetButton(MouseButton.Left, down: false);

        if (!click)
        {
            return;
        }

        float modalW = Math.Min(700f * scale, width - (32f * scale));
        float modalH = Math.Min(410f * scale, height - (32f * scale));
        float modalX = (width - modalW) * 0.5f;
        float modalY = (height - modalH) * 0.5f;

        // Check if clicked outside main modal to dismiss
        if (clickX < modalX || clickX > modalX + modalW || clickY < modalY || clickY > modalY + modalH)
        {
            _cheatsModalOpen = false;
            return;
        }

        // Close (X) in the title bar: a full 48 dp square.
        float barH = 56f * scale;
        float closeXSize = 56f * scale;
        UiRect closeXRect = new(modalX + modalW - closeXSize, modalY, closeXSize, barH);
        if (closeXRect.Contains(clickX, clickY))
        {
            _cheatsModalOpen = false;
            return;
        }

        float contentY = modalY + barH + (12f * scale);
        float rowHeight = 62f * scale;

        // Each cheat row is tappable across its whole width, not just on its
        // toggle button: the row rect is the hit area, the button is the state.
        bool ToggleRow(float rowY)
        {
            if (clickX >= modalX && clickX <= modalX + modalW && clickY >= rowY && clickY <= rowY + rowHeight)
            {
                return true;
            }

            return false;
        }

        // Row 0: Infinite Health
        float r0Y = contentY;
        if (ToggleRow(r0Y))
        {
            PlayerCheatCVars.InfiniteHealth.Value = !PlayerCheatCVars.InfiniteHealth.Value;
            state.Console.SaveSettings();
            HostConfiguration.Save(_configuration, _logger);
            return;
        }

        // Row 1: Infinite Ammo
        float r1Y = contentY + rowHeight;
        if (ToggleRow(r1Y))
        {
            PlayerCheatCVars.InfiniteAmmo.Value = !PlayerCheatCVars.InfiniteAmmo.Value;
            state.Console.SaveSettings();
            HostConfiguration.Save(_configuration, _logger);
            return;
        }

        // Row 2: All Weapons
        float r2Y = contentY + (rowHeight * 2f);
        if (ToggleRow(r2Y))
        {
            PlayerCheatCVars.AllWeapons.Value = !PlayerCheatCVars.AllWeapons.Value;
            state.Console.SaveSettings();
            HostConfiguration.Save(_configuration, _logger);
            return;
        }

        // Row 3: Unlock All Missions
        float r3Y = contentY + (rowHeight * 3f);
        if (ToggleRow(r3Y))
        {
            PlayerCheatCVars.UnlockAllLevels.Value = !PlayerCheatCVars.UnlockAllLevels.Value;
            state.Console.SaveSettings();
            HostConfiguration.Save(_configuration, _logger);
            return;
        }

        // Close button at bottom
        float closeW = 220f * scale;
        float closeH = 56f * scale;
        float closeX = modalX + ((modalW - closeW) * 0.5f);
        float closeY = modalY + modalH - closeH - (14f * scale);
        if (clickX >= closeX && clickX <= closeX + closeW && clickY >= closeY && clickY <= closeY + closeH)
        {
            _cheatsModalOpen = false;
        }
    }

    private void DrawCheatsOverlay(FrameLoopState state)
    {
        bool isMainMenu = _session.Mission == null && !_menuFlow.PauseMenu && state.Shell?.Stack.Top is MainMenuScreen;
        if (!isMainMenu)
        {
            return;
        }

        // The strip stays off the drone view while a run is going, and off the
        // first-run prompt while it asks.
        if (BenchmarkRunning || _benchmarkPromptUp)
        {
            return;
        }

        _shellType ??= UiFontLibrary.Typography(_device);

        float width = SafeWindowWidth;
        float height = SafeWindowHeight;
        float scale = Math.Clamp(height / 480f, 1f, 3f);

        _device.BeginStageTiming(RenderStage.UserInterface);
        _device.Set2DProjection(SafeWindowWidth, SafeWindowHeight);
        state.Batch.Begin();

        var painter = UiPainter.Create(state.Batch, new LayoutContext(SafeWindowWidth, SafeWindowHeight));

        Bgra32 accent = Bgra32.FromRgb(80, 160, 255);
        Bgra32 panel = Bgra32.FromRgb(8, 16, 30);
        Bgra32 textPrimary = Bgra32.FromRgb(235, 242, 250);
        Bgra32 textSecondary = Bgra32.FromRgb(150, 175, 190);

        // ── 1. Main-menu strip: labelled 48 dp rows, top-right ──────────────
        // One row per entry, glyph + label, opaque dark with the accent hairline.
        foreach (MenuStripRow row in MenuStripRows(width, scale))
        {
            Bgra32 fill = panel;
            Bgra32 glyphColor = accent;
            Bgra32 labelColor = textPrimary;

            painter.FillRect(row.Rect, fill);
            painter.StrokeRect(row.Rect, 1.5f * scale, accent);

            // Glyph box: 28 units, left of the row.
            float gx = row.Rect.X + (14f * scale);
            float gy = row.Rect.Y + (14f * scale);
            float gs = scale;
            switch (row.Action)
            {
                case MenuStripAction.Cheats:
                    DrawGearGlyph(painter, gx + (14f * gs), gy + (14f * gs), 7f * gs, glyphColor, fill);
                    break;

                case MenuStripAction.Benchmark:
                    // Three ascending bars: the benchmark glyph.
                    float barW = 5f * gs;
                    float barBase = gy + (24f * gs);
                    painter.FillRect(new UiRect(gx + (4f * gs), barBase - (8f * gs), barW, 8f * gs), glyphColor);
                    painter.FillRect(new UiRect(gx + (11.5f * gs), barBase - (14f * gs), barW, 14f * gs), glyphColor);
                    painter.FillRect(new UiRect(gx + (19f * gs), barBase - (20f * gs), barW, 20f * gs), glyphColor);
                    break;

                case MenuStripAction.Settings:
                    // Three slider tracks with a knob on each.
                    float trackX = gx + (5f * gs);
                    float trackW = 18f * gs;
                    float trackH = 2f * gs;
                    float knob = 5f * gs;
                    float[] trackY = [gy + (7f * gs), gy + (13f * gs), gy + (19f * gs)];
                    float[] knobX = [gx + (8f * gs), gx + (15f * gs), gx + (11f * gs)];
                    for (int i = 0; i < 3; i++)
                    {
                        painter.FillRect(new UiRect(trackX, trackY[i], trackW, trackH), glyphColor);
                        painter.FillRect(new UiRect(knobX[i], trackY[i] - (1.5f * gs), knob, knob), glyphColor);
                    }

                    break;
            }

            if (_shellType is { } labelType)
            {
                string label = MenuStripLabel(row.Action);
                painter.DrawText(labelType.Heading, label,
                    new UiVec2(row.Rect.X + (50f * scale), row.Rect.Y + (21f * scale)),
                    14f * scale, labelColor);
            }
        }

        // ── 2. Cheats Modal Overlay ───────────────────────────────────────
        if (_cheatsModalOpen)
        {
            // Dim background
            painter.FillRect(new UiRect(0f, 0f, width, height), Bgra32.FromRgba(0, 0, 0, 215));

            float modalW = Math.Min(700f * scale, width - (32f * scale));
            float modalH = Math.Min(410f * scale, height - (32f * scale));
            float modalX = (width - modalW) * 0.5f;
            float modalY = (height - modalH) * 0.5f;

            // Main modal box: opaque dark, accent hairline.
            painter.FillRect(new UiRect(modalX, modalY, modalW, modalH), panel);
            painter.StrokeRect(new UiRect(modalX, modalY, modalW, modalH), 1.5f * scale, accent);

            // Modal Title Bar
            float barH = 56f * scale;
            painter.FillRect(new UiRect(modalX, modalY, modalW, barH), Bgra32.FromRgb(18, 32, 60));
            painter.FillRect(new UiRect(modalX, modalY + barH, modalW, 1.5f * scale), accent);

            if (_shellType is { } type)
            {
                painter.DrawText(type.Heading, "CHEATS", new UiVec2(modalX + (20f * scale), modalY + (19f * scale)), 17f * scale, accent);

                // Close (X) in the title bar, a full 48 dp square.
                const string closeGlyph = "X";
                UiVec2 closeExtent = type.Heading.Measure(closeGlyph, 20f * scale);
                painter.DrawText(type.Heading, closeGlyph,
                    new UiVec2(modalX + modalW - (56f * scale) + ((56f * scale - closeExtent.X) * 0.5f),
                        modalY + ((barH - closeExtent.Y) * 0.5f)),
                    20f * scale, accent);
            }

            float contentY = modalY + barH + (12f * scale);
            float rowHeight = 62f * scale;
            float btnW = 110f * scale;
            float btnH = 56f * scale;
            float btnX = modalX + modalW - btnW - (20f * scale);

            void DrawCheatRow(int index, string title, string subtitle, bool active, string activeText = "ON", string inactiveText = "OFF")
            {
                float rowY = contentY + (index * rowHeight);
                float textX = modalX + (20f * scale);

                if (_shellType is { } tp)
                {
                    painter.DrawText(tp.Heading, title, new UiVec2(textX, rowY + (4f * scale)), 15f * scale, textPrimary);
                    painter.DrawText(tp.Mono, subtitle, new UiVec2(textX, rowY + (25f * scale)), 11f * scale, textSecondary);
                }

                // The toggle button is 48 dp tall, centred in its row; the whole
                // row is the tap target (see UpdateCheatsOverlay).
                float btnY = rowY + ((rowHeight - btnH) * 0.5f);
                UiRect bRect = new(btnX, btnY, btnW, btnH);
                string buttonText = active ? $"[ {activeText} ]" : $"[ {inactiveText} ]";
                if (active)
                {
                    painter.FillRect(bRect, Bgra32.FromRgb(60, 130, 220));
                    painter.StrokeRect(bRect, 1.5f * scale, Bgra32.FromRgb(140, 200, 255));
                }
                else
                {
                    painter.FillRect(bRect, Bgra32.FromRgb(25, 32, 50));
                    painter.StrokeRect(bRect, 1f * scale, Bgra32.FromRgb(70, 100, 140));
                }

                if (_shellType is { } tpBtn)
                {
                    UiVec2 btnExtent = tpBtn.Mono.Measure(buttonText, 14f * scale);
                    painter.DrawText(tpBtn.Mono, buttonText,
                        new UiVec2(btnX + ((btnW - btnExtent.X) * 0.5f), btnY + ((btnH - btnExtent.Y) * 0.5f)),
                        14f * scale, active ? textPrimary : Bgra32.FromRgb(140, 165, 200));
                }
            }

            DrawCheatRow(0, "INFINITE HEALTH", "Zero damage from bullets, explosions, falls and electric fences", PlayerCheatCVars.InfiniteHealth.Value);
            DrawCheatRow(1, "INFINITE AMMUNITION", "Magazines stay filled, reserves never deplete while firing", PlayerCheatCVars.InfiniteAmmo.Value);
            DrawCheatRow(2, "ALL WEAPONS", "Adds all weapons into inventory for the mission", PlayerCheatCVars.AllWeapons.Value);
            DrawCheatRow(3, "UNLOCK ALL MISSIONS", $"All {_missions.InProgressionOrder().Count()} missions are selectable in Campaign", PlayerCheatCVars.UnlockAllLevels.Value);

            // The last finished run, when there is one, is the proof it ran: date, tier picked
            // and per-tier 1% low FPS, from r_benchmark_last. A run that was skipped writes
            // nothing there, so the line keeps the last finished run's record. The benchmark
            // itself no longer lives in this modal: run it from the BENCHMARK row on the
            // main-menu strip.
            if (_shellType is { } tpFoot)
            {
                string lastRun = BenchmarkCVars.LastRun.Value.Length > 0
                    ? $"LAST BENCHMARK: {BenchmarkCVars.LastRun.Value}"
                    : "NO BENCHMARK RUN YET - START ONE FROM THE BENCHMARK BUTTON.";
                painter.DrawText(tpFoot.Mono, lastRun,
                    new UiVec2(modalX + (20f * scale), modalY + (322f * scale)),
                    11f * scale, textSecondary);
            }

            // Close button
            float closeW = 220f * scale;
            float closeH = 56f * scale;
            float closeX = modalX + ((modalW - closeW) * 0.5f);
            float closeY = modalY + modalH - closeH - (14f * scale);
            UiRect cRect = new(closeX, closeY, closeW, closeH);
            painter.FillRect(cRect, Bgra32.FromRgb(18, 32, 60));
            painter.StrokeRect(cRect, 1.5f * scale, accent);
            if (_shellType is { } tpClose)
            {
                const string closeText = "[ CLOSE ]";
                UiVec2 closeTextExtent = tpClose.Heading.Measure(closeText, 15f * scale);
                painter.DrawText(tpClose.Heading, closeText,
                    new UiVec2(closeX + ((closeW - closeTextExtent.X) * 0.5f), closeY + ((closeH - closeTextExtent.Y) * 0.5f)),
                    15f * scale, accent);
            }
        }

        state.Batch.End();
        _device.EndStageTiming();
    }

    // Geometric gear glyph: 8 teeth, hub and axle hole, centred on (centerX, centerY).
    private static void DrawGearGlyph(UiPainter painter, float centerX, float centerY, float radius, Bgra32 color, Bgra32 holeColor)
    {
        float toothW = radius * 0.45f;
        float toothL = radius * 0.6f;
        float diag = radius * 0.707f;
        float halfTooth = toothW * 0.5f;

        // Straight teeth
        painter.FillRect(new UiRect(centerX - halfTooth, centerY - radius - toothL, toothW, toothL), color);
        painter.FillRect(new UiRect(centerX - halfTooth, centerY + radius, toothW, toothL), color);
        painter.FillRect(new UiRect(centerX - radius - toothL, centerY - halfTooth, toothL, toothW), color);
        painter.FillRect(new UiRect(centerX + radius, centerY - halfTooth, toothL, toothW), color);
        // Diagonal teeth
        painter.FillRect(new UiRect(centerX + diag - halfTooth, centerY - diag - halfTooth, toothW, toothW), color);
        painter.FillRect(new UiRect(centerX - diag - halfTooth, centerY - diag - halfTooth, toothW, toothW), color);
        painter.FillRect(new UiRect(centerX + diag - halfTooth, centerY + diag - halfTooth, toothW, toothW), color);
        painter.FillRect(new UiRect(centerX - diag - halfTooth, centerY + diag - halfTooth, toothW, toothW), color);

        // Gear Hub & axle hole
        painter.FillRect(new UiRect(centerX - radius, centerY - radius, radius * 2f, radius * 2f), color);
        painter.FillRect(new UiRect(centerX - (radius * 0.4f), centerY - (radius * 0.4f), radius * 0.8f, radius * 0.8f), holeColor);
    }
}
