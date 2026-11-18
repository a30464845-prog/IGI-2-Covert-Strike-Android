using ProjectIGI.Core.Configuration;

namespace ProjectIGI.Host.Configuration;

/// <summary>Whether the first-run benchmark has been run, and whether its prompt was dismissed for good.</summary>
/// <remarks>
/// Archived, so the answers survive to the next launch. <c>r_benchmark_done</c> records that a run
/// started; it never gates the prompt. The prompt itself is gated only by
/// <c>r_benchmark_prompt_dismissed</c>: answering "Yes" runs the benchmark and leaves the prompt
/// armed for a later launch, while "Yes (dont show it again)" runs it and sets the flag, so the
/// prompt never appears again (see <c>GameHost.Benchmark</c>).
/// </remarks>
[CVarContainer]
public static class BenchmarkCVars
{
    /// <summary>Whether the first-run benchmark has finished or been skipped.</summary>
    public static readonly BoolCVar BenchmarkDone = CVar.Bool(
        "r_benchmark_done",
        false,
        CVarOptions.Archive,
        "Whether the first-run benchmark has finished or been skipped; set so it never runs unprompted again.");

    /// <summary>Whether the first-run benchmark prompt was answered "Yes (dont show it again)".</summary>
    public static readonly BoolCVar PromptDismissed = CVar.Bool(
        "r_benchmark_prompt_dismissed",
        false,
        CVarOptions.Archive,
        "Whether the first-run benchmark prompt was dismissed for good; set so it never asks again.");

    /// <summary>Summary of the last benchmark run that reached its results screen.</summary>
    /// <remarks>
    /// Archived, so the proof survives to the next launch: the date, the tier picked and each measured
    /// tier's 1% low FPS, for example "09 Nov 16:40 UTC - Medium - H24 M38 L-- FPS 1% low" (a tier that
    /// was never measured, because a higher tier already held the bar, shows as --). Empty when no run
    /// has finished. Skipped runs write nothing here: a skip is not a measurement. Shown on the cheats
    /// menu's BENCHMARK row, so the last run is visible without opening a log.
    /// </remarks>
    public static readonly StringCVar LastRun = CVar.Text(
        "r_benchmark_last",
        "",
        CVarOptions.Archive,
        "Summary of the last benchmark run: date, chosen tier and per-tier 1% low FPS; empty when no run has finished.");
}
