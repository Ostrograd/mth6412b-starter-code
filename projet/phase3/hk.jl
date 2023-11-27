using BenchmarkTools
using Combinatorics

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



"""Gets closest edges in a tree, not neccessairly leaves."""
function get_closest_edges(graph::Graph, departure_node::Node)
    shortest_edge_vec = Vector{Edge}(undef, 2)
    shortest_dist_vec = Vector{Float64}([Inf, Inf])
    for  edge in edges(graph)
        node1, node2 = nodes(edge)
        if name(node1) == name(departure_node) || name(node2) == name(departure_node)
            #copies over the previous best to second best
            if weight(edge) < shortest_dist_vec[1]

                if shortest_dist_vec[1]< shortest_dist_vec[2]
                    shortest_dist_vec[2] = shortest_dist_vec[1]
                    shortest_edge_vec[2] = shortest_edge_vec[1]
                end
                shortest_dist_vec[1] = weight(edge)
                shortest_edge_vec[1] = edge
            elseif weight(edge) < shortest_dist_vec[2]
                shortest_dist_vec[2] = weight(edge)
                shortest_edge_vec[2] = edge
            end
        end
    end
    return  shortest_edge_vec[1], shortest_edge_vec[2]
end

"""Gets all of the leaves in a graph"""
function get_leaves(graph::Graph)
    leaves = []
    adj_dict = adjacency_dict(graph)
    for node in keys(adj_dict)
        if length(keys(adj_dict[node])) == 1
            push!(leaves, node)
        end
    end
    return leaves
end

"""Gets all of the leaves in a tree"""
function get_leaves(tree::Tree)
    leaves = []
    for node in nodes(tree)
        if length(children(tree, node)) == 0
            push!(leaves, node)
        end
    end
    return leaves
end

"""Searches the tree for the closest leaves to a given node outside of the tree"""
function get_closest_leaves(tree::Tree, graph::Graph,departure_node::Node)
    ##Gets all of the nodes with tree get_closest_leaves
    shortest_edge_vec = Vector{Edge}(undef, 2)
    shortest_dist_vec = Vector{Float64}([Inf, Inf])
    leaves = get_leaves(tree)
    for  edge in edges(graph)
        node1, node2 = nodes(edge)
        for leaf in leaves
            if (name(node1) == name(departure_node) || name(node2) == name(departure_node)) && (name(node1) == name(leaf) || name(node2) == name(leaf))
                #copies over the previous best to second best
                if weight(edge) < shortest_dist_vec[1]
                    if shortest_dist_vec[1]< shortest_dist_vec[2]
                        shortest_dist_vec[2] = shortest_dist_vec[1]
                        shortest_edge_vec[2] = shortest_edge_vec[1]
                    end
                    shortest_dist_vec[1] = weight(edge)
                    shortest_edge_vec[1] = edge
                elseif weight(edge) < shortest_dist_vec[2]
                    shortest_dist_vec[2] = weight(edge)
                    shortest_edge_vec[2] = edge
                end
            end
        end
    end
    return  shortest_edge_vec[1], shortest_edge_vec[2]
end


"""Returns the one tree for the hk heuristic"""
function find_one_tree(graph::Graph, departure_node::Node; edge_selector::String ="leaves", tree_algorithm::Function = prims_algorithm)
    #Copies graph to feed into prim's algorithm
    start_graph = deepcopy(graph)
    #removes the departure node from the graph and saves its index
    idx = remove_node!(start_graph, departure_node)
    remove_edges!(start_graph, departure_node)
    #uses prims algorithm to find the one_tree
    one_tree, root = tree_algorithm(start_graph, start_node_name = name(departure_node))
    #converts the prims algorithm to a graph
    one_tree_graph = tree_to_graph(one_tree, root)
    #finds the second shortest edge from the departure node
    if edge_selector == "leaves"
        shortest_edge_1, shortest_edge_2   = get_closest_leaves(one_tree, graph, departure_node)
    else
        shortest_edge_1, shortest_edge_2   = get_closest_edges(graph, departure_node)
    end
    add_node!(one_tree_graph, departure_node, idx)
    add_edge!(one_tree_graph,shortest_edge_1)
    add_edge!(one_tree_graph,shortest_edge_2)
    one_tree_distance = sum_of_weights(one_tree_graph)
    return one_tree_distance, one_tree_graph
end


"""Changes the edge weights of a graph given the pis"""
function update_edge_weights!(graph::Graph, pis::Vector{Float64})
    correspondance_dict = Dict()
    for (i, node) in enumerate(nodes(graph))
        correspondance_dict[name(node)] = i
    end
    for edge in edges(graph)
        node1, node2 = nodes(edge)
        node1_idx = correspondance_dict[name(node1)]
        node2_idx = correspondance_dict[name(node2)]
        new_weight = weight(edge) + pis[node1_idx] + pis[node2_idx]
        set_weight!(edge, new_weight)
    end
end

"""function that returns the departure node, if not nothing, else returns first node in graph"""
function default_departure_node_selector(graph::Graph, departure_node::Union{Node, Nothing} = nothing)
    if isnothing(departure_node)
        return nodes(graph)[1]
    end
    return departure_node
end

function random_departure_node_selector(graph::Graph,departure_node::Union{Node, Nothing} = nothing)
    return nodes(graph)[rand(1:length(nodes(graph)))]
end

"""subgradient heuristic for calculating a minimal tour"""
function lkh_subgradient(start_graph::Graph;  
    departure_node::Union{Node, Nothing} = nothing, 
    departure_node_selector::Function = default_departure_node_selector,
    t_k_method::String = "1/k", 
    tree_algorithm::Function = prims_algorithm,
    stop_k::Int = 1000000)
    #initialisation of variables for tk calculation
    start_weight = sum_of_weights(start_graph)  
    no_nodes = length(nodes(start_graph))
    #choose starting node if none is given
    departure_node = departure_node_selector(start_graph, departure_node)
    graph = deepcopy(start_graph)
    k = 0
    t_k = 0
    w = -Inf
    pis = zeros(length(nodes(graph)))
    adjacency_list = adjacency_dict(graph)

    while k < stop_k
        iter_time = time()
        total_distance, one_tree = find_one_tree(graph, departure_node, edge_selector = "leaves", tree_algorithm=tree_algorithm)
        weights_k = total_distance - 2 * sum(pis)
        w = max(w, weights_k)
        v_k = degree(one_tree) .- 2
        #Calculates the l1 norm of v_k
        
        if v_k == zeros(length(nodes(graph)))
            return total_distance, one_tree
        end
        if t_k_method == "1/k"
            t_k = 1/(k+1)
        elseif t_k_method == "sqrt"
            t_k = 10/ (sqrt(k+1))
        elseif t_k_method == "weights/k"
            t_k = start_weight/(100*no_nodes + k)
        else
            if k == 0
                t_k = start_weight/1000
            elseif mod(no_nodes, k) == 0
                t_k = start_weight/(1000* (k+1))
            end
        end
        pis = pis + t_k * v_k
        k = k + 1
        update_edge_weights!(graph, pis)
        v_k_norm  = sum(broadcast(abs, v_k))
        println("k = ", k," step= ", t_k, " time = ", time() - iter_time, " VK_norm ", v_k_norm )
    end
    return Inf, nothing
end

"""Exact algorithm for calculating TSP"""
function h_k_exact_algorithm(g::Graph ; start_node_name::Any = nothing)
    #if no start node name, first node is start node
    if isnothing(start_node_name)
        start_node_name = name(nodes(g)[1])
    end
    #move start node to first position of graph
    for (i, node) in enumerate(nodes(g))
        if name(node) == start_node_name
            g.nodes[1], g.nodes[i] = g.nodes[i], g.nodes[1]
            break
        end
    end
    #create adjacency list
    adjacency_list = adjacency_dict(g)
    distance_dict = Dict()
    for k in 2:length(nodes(g))
        distance_dict[(Set([k]), k)] = Dict("c" =>adjacency_list[1][k], "p"=> [1, k])
    end
    for s in 2:length(nodes(g))-1
        for subset in combinations(2:length(nodes(g)), s)
            for k in subset
                min_dist = Inf
                for m in subset 
                    if m !=k
                        predecessor = distance_dict[(setdiff(Set(subset), Set([k])), m)]
                        dist = predecessor["c"] + adjacency_list[m][k]
                        if dist < min_dist
                            min_dist = dist
                            min_m = m
                            new_list = copy(predecessor["p"])
                            append!(new_list, k)
                            distance_dict[(Set(subset), k)] = Dict("c" => min_dist, "p" => new_list)
                        end
                    end
                end
            end
        end
    end

    #returns the minimum path from the start node that goes to all of the other paths
    min = Inf
    final_path = []
    for k in 2:length(nodes(g))
        distance = distance_dict[(Set(2:length(nodes(g))), k)]["c"] + adjacency_list[k][1]
        println("distance = ", distance)
        if distance < min
            println("distance = ", distance)
            min = distance
            final_path = copy(distance_dict[(Set(2:length(nodes(g))), k)]["p"])
            append!(final_path, 1)
        end
    end
    return min, final_path
end

"""Brute force calculates TSP solution"""
function brute_force_tsp(g::Graph, start_node::Any)
    adjacency_list = adjacency_dict(g)
    g_nodes = nodes(g)
    nodes_perm = collect(permutations(collect(1:length(g_nodes))))
    min_dist = Inf
    min_perm = []
    for perm in nodes_perm
        dist = 0
        for i in 1:length(perm)-1
            dist += adjacency_list[perm[i]][perm[i+1]]
        end
        dist += adjacency_list[perm[end]][perm[1]]
        #println("permutation", perm)
        #println("dist = ", dist)
        if dist < min_dist
            min_dist = dist
            min_perm = perm
        end
        
    end
    return min_dist, min_perm
end

#Functions that creates a 2d vector of the adjacency matrix
function get_adjacency_matrix(graph::Graph)
    adjacency_list = adjacency_dict(graph)
    adjacency_matrix = zeros(length(nodes(graph)), length(nodes(graph)))
    for i in 1:length(nodes(graph))
        for j in 1:length(nodes(graph))
            if haskey(adjacency_list[i], j)
                adjacency_matrix[i,j] = adjacency_list[i][j]
            else
                adjacency_matrix[i,j] = Inf
            end
        end
    end
    return adjacency_matrix
end

#Greedy heuristic for TSP problem
function greedy_tsp(graph::Graph{Y,T}, departure_node::Union{Node, Nothing} = nothing) where {Y,T}
    #Creates an adjacency matrix of the graph
    adjacency_matrix = get_adjacency_matrix(graph)
    start_adj = copy(adjacency_matrix)
    correspondance_dict = Dict()
    for (i, node) in enumerate(nodes(graph))
        correspondance_dict[name(node)] = i
    end
    #Chooses the departure node
    current_node = default_departure_node_selector(graph, departure_node)
    current_idx = correspondance_dict[name(current_node)]
    nearest_neighbor_idx = current_idx
    best_nearest_neighbor_idx = current_idx
    #Defines tour graph
    tour_graph = Graph("Tour", Node{Y}[], Edge{T,Y}[])
    #Go to nearest node. After node is visited, set its distance to infinity for all other nodes
    for node in nodes(graph)
        best_edge_weight = Inf
        for (neighbor_idx, edge_weight) in enumerate(adjacency_matrix[current_idx, :])
            if adjacency_matrix[current_idx, neighbor_idx] < best_edge_weight
                best_edge_weight = adjacency_matrix[current_idx, neighbor_idx]
                best_nearest_neighbor_idx = neighbor_idx
            end
            nearest_neighbor_idx = best_nearest_neighbor_idx
        end
        nearest_neighbor = nodes(graph)[nearest_neighbor_idx]
        #adds an edge to the tour graph
        add_edge!(tour_graph, Edge(current_node, nearest_neighbor, best_edge_weight))
        current_node = nearest_neighbor
        current_idx = nearest_neighbor_idx
        #removes the node from consideration by setting it to infinity.
        adjacency_matrix[:, nearest_neighbor_idx] .= Inf
    end
    # #Adds the last edge to the tour
    add_edge!(tour_graph, Edge(nodes(tour_graph)[end], nodes(tour_graph)[1], 
    start_adj[correspondance_dict[name(nodes(tour_graph)[end])], 
    correspondance_dict[name(nodes(tour_graph)[1])]]))
    return tour_graph
end