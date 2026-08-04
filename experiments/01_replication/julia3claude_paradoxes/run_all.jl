# Run every paradox file in order:  julia paradoxes/run_all.jl
for f in sort(readdir(@__DIR__))
    endswith(f, ".jl") && f != "run_all.jl" || continue
    println("\n", "═"^70, "\n  ", f, "\n", "═"^70)
    include(joinpath(@__DIR__, f))
end
