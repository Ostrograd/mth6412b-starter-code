include("../phase1/graph.jl")
include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase2/comp_connexes.jl")
include("../phase2/Kruskal.jl")
include("../phase2/heuristics.jl")
include("../phase3/hk.jl")
include("../phase3/rsl.jl")
include("tools.jl")

##############################################

graph = graph_from_tsp("instances/tsp/instances/nikos-cat.tsp","graphe")[1]
cycle,nodes_list = rsl(graph, nodes(graph)[1], "Prim")
nodes_index_list = Array{Int}(undef, length(nodes_list))
nodes_list[2]
i=1

#graph, tournee = brute_force_tsp(graph, nodes(graph)[1])  ##J'ai testé le brute_force, mais il overflow
for node in nodes_list
    idx = node.index        #Construit la liste des indices de la tournée trouvée
    nodes_index_list[i] = idx - 1
    i += 1
end

tour = "cat.tour"
tour_theorique = "instances/tsp/tours/nikos-cat.tour"
write_tour("cat.tour",nodes_index_list, sum_of_weights(cycle))

reconstruct_picture(tour, "instances/images/shuffled/nikos-cat.png", "nikos-cat-reconstruit.png",view = true)