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
                        #println("predecessor", predecessor)
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




#Fully connected graph with 7 edges
a = Node("a",[0.])
b = Node("b",[0.])
c = Node("c",[0.])
d = Node("d",[0.])
e = Node("e",[0.])
f = Node("f",[0.])
g = Node("g",[0.])
node_list = [a,b,c, d,e, f, g]
#Edges are fully connected
edge1 = Edge(a,b, 4.)
edge2 = Edge(a,c, 8.)
edge3 = Edge(a, d, 11.)
edge4 = Edge(a, e, 8.)
edge5 = Edge(a, f, 7.)
edge6 = Edge(a, g, 1.)
edge7 = Edge(b, c, 6.)
edge8 = Edge(b, d, 2.)
edge9 = Edge(b, e, 4.)
edge10 = Edge(b, f, 7.)
edge11 = Edge(b, g, 2.)
edge12 = Edge(c, d, 7.)
edge13 = Edge(c, e, 1.)
edge14 = Edge(c, f, 6.)
edge15 = Edge(c, g, 3.)
edge16 = Edge(d, e, 5.)
edge17 = Edge(d, f, 4.)
edge18 = Edge(d, g, 8.)
edge19 = Edge(e, f, 2.)
edge20 = Edge(e, g, 7.)
edge21 = Edge(f, g, 3.)
edge_list = [edge1, edge2, edge3, edge4, edge5, edge6,
                edge7, edge8, edge9, edge10, edge11,
                edge12, edge13, edge14, edge15, edge16,
                edge17, edge18, edge19, edge20, edge21]
#creates the graph
tsp_test2 = Graph("Test2",node_list,edge_list)


# graphe_test = Graph("Test",Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])


# score, test2_graph = lkh_subgradient(tsp_test2, t_k_method = "weights/k")
# println(score)

# gr17_graph, gr17_nodes = graph_from_tsp("instances/stsp/gr17.tsp","graphe1")
# println("running h_k_algorithm on gr17")
# @time total_distance, one_tree = lkh_subgradient(gr17_graph, t_k_method = "weights/k", departure_node= nodes(gr17_graph)[2], tree_algorithm = prims_algorithm, departure_node_selector = random_departure_node_selector)