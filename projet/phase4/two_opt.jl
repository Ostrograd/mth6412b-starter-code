include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase2/comp_connexes.jl")
include("../phase2/Kruskal.jl")
include("../phase2/heuristics.jl")
include("../phase3/hk.jl")
include("../phase3/rsl.jl")
include("tools.jl")
using(Plots)
#
#Swaps two edges in a tour
function two_opt_swap(tour::Vector{Int},adj_dict::Dict, i::Int, k::Int, previous_cost::Float64)
    node1 = tour[i]
    if i == length(tour)
        node2 = tour[1]
    else
        node2 = tour[i+1]
    end
    node3 = tour[k]
    if k == length(tour)
        node4 = tour[1]
    else
    node4 = tour[k+1]
    end

    new_tour = Vector{Int64}([])
    #Returns the old cycle if the two edges are adjacent
    if node1 == node3 || node1 == node4 || node2 == node3 || node2 == node4
        return tour, previous_cost
    end
    for j in range(1,i)
        push!(new_tour, tour[j])
    end
    for j in range(k,i+1, step = -1)
        push!(new_tour, tour[j])
    end
    for j in range( k+1, length(tour))
        push!(new_tour, tour[j])
    end
    # println()
    # println("The nodes are", node1,' ', node2,' ', node3,' ', node4)
    # println(adj_dict[node1][node2])
    # println(adj_dict[node3][node4])
    # println(adj_dict[node1][node3])
    # println(adj_dict[node2][node4])
    #calculates the new tour cost
    new_cost = previous_cost - adj_dict[node1][node2] - adj_dict[node3][node4] + adj_dict[node1][node3] + adj_dict[node2][node4]

   return new_tour, new_cost
end


"""Looks for a swap that improves the tour"""
function find_swap(tour::Vector{Int},adj_dict::Dict, previous_cost::Float64)
    for i in 1:length(tour)
        for k in 1:length(tour)
            if i != k
                new_tour,new_cost = two_opt_swap(tour,adj_dict, i, k, previous_cost)
                if new_cost < previous_cost
                    # println("found a swap")
                    # println("new cost", new_cost)
                    # println("previous cost", previous_cost)
                    return new_tour, new_cost, true
                end
            end
        end
    end
    return tour, previous_cost, false
end


"""Main two_opt function"""
function two_opt(cycle::Vector{Int} , adjacency_dict::Dict, best_cost::Float64; iter_stop = Inf)
    #println("At the start of two opt, the cost is", previous_cost)
    best_cycle = copy(cycle)
    iter_counter = 0
    improved = true
    while improved && iter_counter < iter_stop
        best_cycle, best_cost, improved = find_swap(best_cycle,adjacency_dict, best_cost)
        iter_counter += 1
    end
    return best_cycle, best_cost
end

"""Runs 2 opt on a tour.  cycle is the cycle to be improved"""
function run_two_opt(original_graph::Graph, cycle_graph::Graph, cycle::Vector{Int64}; iter_stop = Inf)
    adj_dict = adjacency_dict(original_graph)
    original_cost = sum_of_weights(cycle_graph)
    two_opt_cycle , best_cost= two_opt(cycle,adj_dict, original_cost, iter_stop = iter_stop)
    #println("two_opt_cycle", two_opt_cycle)
    println("after two opt", best_cost)
    #turns the cycle into a graph
    two_opt_cycle_graph = Graph("two_opt_cycle", Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])
    for i in 1:length(two_opt_cycle)
        add_node!(two_opt_cycle_graph,nodes(original_graph)[i])
    end
    for i in 1:length(two_opt_cycle)
        if i == length(two_opt_cycle)
            edge = Edge(nodes(original_graph)[two_opt_cycle[i]], nodes(original_graph)[two_opt_cycle[1]], adj_dict[two_opt_cycle[i]][two_opt_cycle[1]])
        else
            edge = Edge(nodes(original_graph)[two_opt_cycle[i]], nodes(original_graph)[two_opt_cycle[i+1]], adj_dict[two_opt_cycle[i]][two_opt_cycle[i+1]])
        end
        add_edge!(two_opt_cycle_graph, edge)
    end
    return two_opt_cycle_graph, two_opt_cycle, sum_of_weights(two_opt_cycle_graph)
end 


#Correspondance dict caclulation function
function correspondance_dict_calculation(cycle::Graph)
    correspondance_dict = Dict()
    for (i, node) in enumerate(nodes(cycle))
        correspondance_dict[name(node)] = i
    end
    return correspondance_dict
end




#Fully connected graph with 7 edges
a = Node("a",[0., 0.3])
b = Node("b",[1.2, 0.1])
c = Node("c",[2.,.5])
d = Node("d",[2.1, 0.1])
e = Node("e",[-0.1, 0.1 ])
f = Node("f",[0.2, 0.3])
g = Node("g",[0.1, 0.2])
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
adj_dict = adjacency_dict(tsp_test2)
#correspondance_dict = correspondance_dict_calculation(tsp_test2)
#score, test2_graph = lkh_subgradient(deepcopy(tsp_test2), t_k_method = "1/k")

# min_dist, min_perm = brute_force_tsp(deepcopy(tsp_test2), nodes(tsp_test2)[1])
# println("min perm", min_perm)
# println("Par brute_force_tsp, la longueur de la tournée optimale est: ",min_dist)

# cycle, nodes_list = rsl(tsp_test2, nodes(tsp_test2)[1], "Prim")
# tour_indexes = Vector{Int64}([])
# for node in nodes_list
#     push!(tour_indexes, index(node))
# end
# println("running two opt")
# two_opt_cycle_graph, two_opt_cycle, two_opt_cost = run_two_opt(tsp_test2,cycle, tour_indexes)
# println("after two opt", two_opt_cost)
# plot_graph(cycle)
# plot_graph(two_opt_cycle_graph)


# gr17 = graph_from_tsp("instances/stsp/gr17.tsp","graphe")[1]
# #show(gr17)
# adj_dict = adjacency_dict(gr17)
# cycle, nodes_list = rsl(gr17, nodes(gr17)[2], "Prim")
# tour_indexes = Vector{Int64}([])
# for node in nodes_list
#     push!(tour_indexes, index(node))
# end
#println("Current cycle")
#show(cycle)
# bayg29 = graph_from_tsp("instances/stsp/bayg29.tsp","graphe")[1]
# cycle, nodes_list = rsl(bayg29, nodes(bayg29)[1], "Prim")
# tour_indexes = Vector{Int64}([])
# for node in nodes_list
#     push!(tour_indexes, index(node))
# end
# println("finished with cost ", sum_of_weights(cycle))
# show(cycle)
# two_opt_cycle_graph, two_opt_cycle, two_opt_cost = run_two_opt(bayg29, cycle, tour_indexes)
# println("after two opt", sum_of_weights(two_opt_cycle_graph))
# show(two_opt_cycle)
# show(two_opt_cycle_graph)
# plot_graph(two_opt_cycle_graph)