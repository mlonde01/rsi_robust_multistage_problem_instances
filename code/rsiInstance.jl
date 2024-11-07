#=
# RSI instance
# created by Mariana Londe (16 nov 2022)
# modified by Mariana Londe (28 jul 2023)
=#

struct rsiInstance #<: AbstractInstance
    instance_name::String
    Dmin::Int64
    Dmax::Int64
    num_neighbors::Int64
    I::Int64
    RSImin::Int64
    RSImax::Int64
    neighbors
    O::Array{Int64}
    tedges

    function rsiInstance(filename::String)

        open(filename) do f
            # control variables for reading
            original = 0
            neigh = 0
            edges = 0
            node = 0
            edge = 0
            # read till end of file
            while ! eof(f)
                # read a new / next line for every iteration          
                s = readline(f)
                fields = split(s," ")
                if fields[1] == "instance_name"
                    global instance_name = fields[2]
                elseif fields[1] == "instance_group"
                    global instance_group = fields[2]
                elseif fields[1] == "rsi_range"
                    global RSImin = parse(Int64, fields[2]) + 1
                    global RSImax = parse(Int64, fields[3]) + 1
                elseif fields[1] == "rsi_min_max_distance"
                    global Dmin = parse(Int64, fields[2])
                    global Dmax = parse(Int64, fields[3])
                elseif fields[1] == "num_nodes"
                    global I = parse(Int64, fields[2])
                elseif fields[1] == "original_rsis"
                    global O = zeros(I)
                    original = 1
                    node = 1
                elseif original == 1 && node ≤ I
                    O[node] = parse(Int64, fields[1])
                    node = node + 1
                elseif fields[1] == "num_neighbors"
                    global num_neighbors = parse(Int64, fields[2])
                    global neighbors = Any[]
                    neigh = 1
                    edge = 1
                elseif neigh == 1 && edge ≤ num_neighbors
                    push!(neighbors, [parse(Int64, fields[1])+1, parse(Int64, fields[2])+1])
                    edge = edge + 1
                end         
            end
        end

        tedges = zeros(I,I)
        for i in 1:num_neighbors
            tedges[neighbors[i][1],neighbors[i][2]] = 1
            tedges[neighbors[i][2],neighbors[i][1]] = 1
        end

        new(instance_name, Dmin, Dmax, num_neighbors, I, RSImin, RSImax, neighbors, O, tedges)
    end
end


struct ms_rsiInstance #<: AbstractInstance
    instance_name::String
    Dmin::Int64
    Dmax::Int64
    num_neighbors::Int64
    I::Int64
    RSImin::Int64
    RSImax::Int64
    neighbors
    O::Array{Int64}
    tedges
    Γ::Float64
    Δ::Float64
    S::Int64
    N::Int64
    s_s_tedges

    function ms_rsiInstance(filename::String)

        open(filename) do f
            # control variables for reading
            original = 0
            neigh = 0
            edges = 0
            node = 0
            edge = 0
            ssted = 0
            line = 0
            stage = 0
            traj = 0
            # read till end of file
            while ! eof(f)
                # read a new / next line for every iteration          
                s = readline(f)
                fields = split(s," ")
                if fields[1] == "instance_name"
                    global instance_name = fields[2]
                elseif fields[1] == "instance_group"
                    global instance_group = fields[2]
                elseif fields[1] == "rsi_range"
                    global RSImin = parse(Int64, fields[2]) + 1
                    global RSImax = parse(Int64, fields[3]) + 1
                elseif fields[1] == "rsi_min_max_distance"
                    global Dmin = parse(Int64, fields[2])
                    global Dmax = parse(Int64, fields[3])
                elseif fields[1] == "num_nodes"
                    global I = parse(Int64, fields[2])
                elseif fields[1] == "original_rsis"
                    global O = zeros(I)
                    original = 1
                    node = 1
                elseif original == 1 && node ≤ I
                    O[node] = parse(Int64, fields[1])
                    node = node + 1
                elseif fields[1] == "num_neighbors"
                    global num_neighbors = parse(Int64, fields[2])
                    global neighbors = Any[]
                    neigh = 1
                    edge = 1
                elseif neigh == 1 && edge ≤ num_neighbors
                    push!(neighbors, [parse(Int64, fields[1])+1, parse(Int64, fields[2])+1])
                    edge = edge + 1
                elseif fields[1] == "gamma"
                    global Γ = parse(Float64, fields[2])
                elseif fields[1] == "delta"
                    global Δ = parse(Float64, fields[2])
                elseif fields[1] == "num_stages"
                    global S = parse(Int64, fields[2])
                elseif fields[1] == "num_trajectories"
                    global N = parse(Int64, fields[2])
                    global s_s_tedges = zeros(Int64, I, I, S, N)
                    ssted = 1
                    stage = 1
                    traj = 1
                    line = stage * traj
                elseif ssted == 1 && line ≤ S * N && stage ≤ S
                    #println(stage,traj)
                    for i in 1:I
                        for j in 1:I
                            #println(fields[(i-1)*I + j],stage,traj)
                            global s_s_tedges[i,j,stage,traj] = parse(Int64,fields[(i-1)*I + j+1])
                        end
                    end
                    if traj < N
                        traj = traj + 1
                    else
                        traj = 1
                        stage = stage + 1
                    end
                    line = (stage-1)*N + traj 
                end         
            end
        end

        tedges = zeros(I,I)
        for i in 1:num_neighbors
            tedges[neighbors[i][1],neighbors[i][2]] = 1
            tedges[neighbors[i][2],neighbors[i][1]] = 1
        end

        new(instance_name, Dmin, Dmax, num_neighbors, I, RSImin, RSImax, neighbors, O, tedges, Γ, Δ, S, N, s_s_tedges)
    end
end


struct best_results_Instance #<: AbstractInstance
    sol_single_stage_model
    sol_brkga_classic
    sol_brkga_dijkstra
    sol_brkga_dijkstra_ws

    function best_results_Instance(filename::String, I::Int64, S::Int64)

        sol_single_stage_model = zeros(I)
        sol_brkga_classic = zeros(I,S)
        sol_brkga_dijkstra = zeros(I,S)
        sol_brkga_dijkstra_ws = zeros(I,S)

        open(filename) do f
            # read till end of file
            while ! eof(f)
                # read a new / next line for every iteration          
                s = readline(f)
                fields = split(s,[' ','\t'])
                if fields[1] == "CLASSIC"
                    for i in 1:I
                        for s in 1:S
                            global sol_brkga_classic[i,s] = parse(Float64,fields[i + (s-1)*I+1])
                        end
                    end
                elseif fields[1] == "DIJKSTRA"
                    for i in 1:I
                        for s in 1:S
                            global sol_brkga_dijkstra[i,s] = parse(Float64,fields[i + (s-1)*I+1])
                        end
                    end
                elseif fields[1] == "DIJKSTRAWS"
                    for i in 1:I
                        for s in 1:S
                            global sol_brkga_dijkstra_ws[i,s] = parse(Float64,fields[i + (s-1)*I+1])
                        end
                    end
                elseif fields[1] == "DETERMINISTIC"
                    for i in 1:I
                        global sol_single_stage_model[i] = parse(Float64,fields[i + 1])
                    end
                end         
            end
        end

        new(sol_single_stage_model,sol_brkga_classic,sol_brkga_dijkstra,sol_brkga_dijkstra_ws)
    end
end