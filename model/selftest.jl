#!/usr/bin/env julia
# W21-Q1: one failure-path test of the model, not the sweep instrument.
# Run: julia --startup-file=no model/selftest.jl
# Stdlib only; all model runs and mutations use a disposable copy. No network.

const EXPECTED = "event seq numbers equal chronological order 1..17"

function run_copy(model_dir)
    output = IOBuffer()
    cmd = `$(Base.julia_cmd()) --startup-file=no $(joinpath(model_dir, "run_model.jl"))`
    process = run(pipeline(ignorestatus(cmd), stdout=output, stderr=output))
    return process.exitcode, String(take!(output))
end

function require_result(condition, message, output)
    condition && return
    print(stderr, output)
    error(message)
end

mktempdir() do sandbox
    model_dir = joinpath(sandbox, "model")
    cp(@__DIR__, model_dir)

    status, output = run_copy(model_dir)
    require_result(status == 0 && count("  [PASS] ", output) == 12 &&
                   occursin("ALL MODEL CHECKS PASSED", output),
                   "unmodified control must pass all 12 checks (exit $status)", output)
    println("  ok   unmodified control: exit 0, 12 checks passed")

    events = joinpath(model_dir, "data", "events.json")
    original = read(events, String)
    target = r"\"seq\":\s*1(?=\s*,)"
    length(collect(eachmatch(target, original))) == 1 ||
        error("fixture drift: expected exactly one event with seq 1")
    # Duplicate 2 rather than using 0 or 18: seq is also used as an array index
    # while printing the report, before the checks. Reach the guard, not a crash.
    write(events, replace(original, target => "\"seq\": 2"; count=1))

    status, output = run_copy(model_dir)
    require_result(status == 1 && occursin("  [FAIL] " * EXPECTED, output) &&
                   occursin("1 CHECK(S) FAILED:", output) &&
                   occursin("  - " * EXPECTED, output) &&
                   count("  [PASS] ", output) == 11,
                   "mutation must exit 1 and name only the sequence check (exit $status)",
                   output)
    println("  ok   seq 1 -> 2: exit 1; [FAIL] ", EXPECTED)
    println("1 failure-path test passed (11 other model checks still pass)")
end
