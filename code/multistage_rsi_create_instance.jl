#=
# multistage RSI problem - create instance
# created by Mariana Londe (16 nov 2022)
# modified by Mariana Londe (28 jul 2023)
=#

function calculateDensity(edges)
    
    sum_edges = sum(edges)/2
    nodes = size(edges, 1)

    return (2 * sum_edges) / (nodes * (nodes - 1))
    
end

using Random, Dates, Distributions

include("rsiInstance.jl")

if length(ARGS) < 7
    println("Usage: julia main.jl <rsi-instance-file> <seed> <number-stages> <number-scenarios> <gamma> <delta> <new_inst_dir>")
    println("Example: julia main.jl long_n0030_r030_150.txt 51311 4 20 0.5 0.4 ./instances") 
    exit(1)
end

instance_file = ARGS[1]
seed = parse(Int64, ARGS[2])
S = parse(Int64, ARGS[3])
N = parse(Int64, ARGS[4])
Γ = parse(Float64, ARGS[5])
Δ = parse(Float64, ARGS[6])
new_inst_dir = ARGS[7]

println("Reading data...")
instance = rsiInstance(instance_file)

Random.seed!(seed)

model_name = "Create instance"
#=
print("""
---------------------------------------------------
> Experiment started at $(Dates.now())
> Instance: $(instance.instance_name)
> Parameters:
-- Model: $(model_name)
-- Number of nodes: $(instance.I)
-- Seed: $seed
-- Γ: $Γ
-- Number of scenarios/stages: $S
-- Number of trajectories: $N
-- Δ: $Δ
""")

println("\n[$(Dates.Time(Dates.now()))] Creating stages...")
=#
I = instance.I
RSImin = instance.RSImin
RSImax = instance.RSImax
Dmin = instance.Dmin
Dmax = instance.Dmax
tedges = instance.tedges

# for each stage, create N possible scenarios, observe their amount of density,
# and use it to calculate probabilities

densities_per_stage_scenarios = zeros(Float64, S, N)
s_s_tedges = zeros(Int64, I, I, S, N)
distributions = Any[]

for i in 1:N
    densities_per_stage_scenarios[1, i] = calculateDensity(tedges)
    s_s_tedges[:,:,1,i] = tedges[:,:]
end

dist = fit(Normal, densities_per_stage_scenarios[1,:])
push!(distributions,dist)

for s in 2:S            
    for st in 1:N
        base = s_s_tedges[:,:,s-1,st]
        signal = rand()
        if signal ≤ Δ
            value = densities_per_stage_scenarios[s-1, st] * (1 + Γ)
        else
            value = densities_per_stage_scenarios[s-1, st] * (1 - Γ)
        end
        for i in 1:I
            for j in 1:I
                chance = rand()
                if chance ≤ value
                    if base[i,j] == 1     # if exists, remove edge
                        s_s_tedges[i,j,s,st] = 0
                        s_s_tedges[j,i,s,st] = 0
                    else                    # if does not exist, create edge
                        s_s_tedges[i,j,s, st] = 1
                        s_s_tedges[j,i,s, st] = 1
                    end
                end
            end
        end
        densities_per_stage_scenarios[s, st] = calculateDensity(s_s_tedges[:,:,s,st])
    end
    
    global dist = fit(Normal, densities_per_stage_scenarios[s,:])
    push!(distributions,dist)
end

print(distributions)

    
#println("\n[$(Dates.Time(Dates.now()))] Writing instance to txt file...")
# write txt file with instance
file_name,dp = split(instance_file, ".")
n0 = instance.instance_name
n1 = string(trunc(Int64, 100 * Γ))
n2 = string(trunc(Int64, 100 * Δ))
n3 = string(S)
n4 = string(N)
nf_name = n0 * "_s" * n3 * "_t" * n4 * "_g" * n1 * "_d" * n2
new_file = new_inst_dir * "/" * nf_name * ".txt"
cp(instance_file, new_file)

hd_text = """
gamma $Γ
delta $Δ
num_stages $S
num_trajectories $N
"""
for s in 1:S
    for t in 1:N
        for i in 1:I
            for j in 1:I
                global hd_text = string(hd_text, " ", s_s_tedges[i,j,s,t])
            end
        end
        global hd_text = string(hd_text, "\n")
    end
end

open(new_file, "a") do f
    write(f, hd_text)
end