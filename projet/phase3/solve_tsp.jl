
include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase1/read_stsp.jl")
include("../phase2/comp_connexes.jl")
include("../phase1/main.jl")
include("../phase2/queue.jl")
include("../phase2/heuristics.jl")
include("../phase2/Kruskal.jl")
include("../phase2/prims_algorithm.jl")
include("../phase3/hk.jl")
include("../phase3/rsl.jl")

function solve_tsp(file_path::String; tsp_method::String = "rsl", start_node_index::Union{Int, Nothing}=nothing, departure_node_selector::Function = random_departure_node_selector, t_k_method::String = "1/k", tree_algorithm::String = "kruskal")
    tsp_graph, tsp_nodes = graph_from_tsp(file_path,"graphe1")
    if isnothing(start_node_index)
        start_node = nodes(tsp_graph)[1]
    else
        start_node = nodes(tsp_graph)[start_node_index]
    end
    if tsp_method == "h_k_algorithm"
        if tree_algorithm =="kruskal"
            println("running h_k_algorithm on ", file_path, " with kruskal")
            @time total_distance, one_tree = lkh_subgradient(tsp_graph, t_k_method = t_k_method, departure_node_selector = departure_node_selector, tree_algorithm = kruskal)
            println(total_distance)
            return total_distance, one_tree
        else
            println("running h_k_algorithm on ", file_path, " with prims")
            @time total_distance, one_tree = lkh_subgradient(tsp_graph, t_k_method = t_k_method, departure_node_selector = departure_node_selector, tree_algorithm = prims_algorithm)
            println(total_distance)
            return total_distance, one_tree
        end
    elseif tsp_method == "rsl"
        if tree_algorithm =="kruskal"
            println("running rsl on ", file_path, " with kruskal")
            @time cycle = rsl(tsp_graph,start_node, "Kruskal")
            println("sum of weights ", sum_of_weights(cycle))
            return sum_of_weights(cycle), cycle
        else
            println("running rsl on ", file_path, " with prims")
            @time cycle = rsl(tsp_graph,start_node, "Prims")
            println("sum of weights ", sum_of_weights(cycle))
            return sum_of_weights(cycle), cycle
        end
    else
        println("Invalid tsp method")
    end
end