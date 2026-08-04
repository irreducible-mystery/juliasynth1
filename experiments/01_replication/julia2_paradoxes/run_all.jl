# run_all.jl — execute the whole paradox suite.
files = ["01_antinomies.jl", "02_mathematical.jl",
         "03_probability.jl", "04_vagueness_selfreference.jl"]
for f in files
    println("\n", "█"^70)
    println("█  RUNNING ", f)
    println("█"^70)
    include(joinpath(@__DIR__, f))
end
println("\n", "█"^70, "\n█  SUITE COMPLETE\n", "█"^70)
