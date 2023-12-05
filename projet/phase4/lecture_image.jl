
include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase2/comp_connexes.jl")
include("../phase2/Kruskal.jl")
include("../phase2/heuristics.jl")
include("../phase3/hk.jl")
include("../phase3/rsl.jl")
include("../phase4/two_opt.jl")
include("tools.jl")

##############################################
#run(`clear`) # clears the terminal screen
function shuffled_image_to_reconstruct(tsp_file::String,shuffled_image::String, new_image_name::String, nbr_of_tests::Int64 = 5; two_opt_iter_stop = 3000)
    graph = graph_from_tsp(tsp_file,"graphe")[1]
    println("Calculating a tour")
   #Tries rsl nbr_of_tests times and keeps the best one
    cycle, nodes_list = semi_optimal_rsl(graph, nbr_of_tests)
    println("rsl finished with cost ", sum_of_weights(cycle))
    #setting up 2-opt
    tour_indexes = Vector{Int64}([])
    for node in nodes_list
        push!(tour_indexes, index(node))
    end
    println("running two opt")
    @time two_opt_cycle_graph, two_opt_cycle, two_opt_cost = run_two_opt(graph,cycle, tour_indexes, iter_stop = two_opt_iter_stop)
    #Makes sure the cycle starts with 0
    one_index = findfirst(x -> x==1,two_opt_cycle)
    two_opt_cycle_mod = [two_opt_cycle[one_index:end] ; two_opt_cycle[1:one_index-1]]
    nodes_index_list = two_opt_cycle_mod .- 1
    println("2 opt finished with cost ", sum_of_weights(two_opt_cycle_graph))
    
    
    tour = new_image_name * ".tour"
    write_tour(tour,nodes_index_list, sum_of_weights(two_opt_cycle_graph))
    
    reconstruct_picture(tour, shuffled_image, new_image_name * "-reconstruit.png",view = true)
end

# graph = graph_from_tsp("instances/tsp/instances/nikos-cat.tsp","graphe")[1]
# println("Calculating a tour")
# #@time cycle,nodes_list = rsl(graph, nodes(graph)[1], "Prim")
# cycle, nodes_list = semi_optimal_rsl(graph, 3)
# println("rsl finished with cost ", sum_of_weights(cycle))
# tour_indexes = Vector{Int64}([])
# for node in nodes_list
#     push!(tour_indexes, index(node))
# end
# println("running two opt")
# @time two_opt_cycle_graph, two_opt_cycle, two_opt_cost = run_two_opt(graph,cycle, tour_indexes, iter_stop = 3000)

# one_index = findfirst(x -> x==1,two_opt_cycle)
# two_opt_cycle_mod = [two_opt_cycle[one_index:end] ; two_opt_cycle[1:one_index-1]]

# nodes_index_list = two_opt_cycle_mod .- 1
# println("2 opt finished with cost ", sum_of_weights(two_opt_cycle_graph))

# nodes_list[2]


# #graph, tournee = brute_force_tsp(graph, nodes(graph)[1])  ##J'ai testé le brute_force, mais il overflow
# # nodes_index_list = Array{Int}(undef, length(nodes_list))
# # for (i,node) in enumerate(nodes_list)
# #     idx = node.index        #Construit la liste des indices de la tournée trouvée
#     #     println("the node is", idx)
# #     nodes_index_list[i] = idx - 1
# # end
# minimum(nodes_index_list)
# image_name = "IMAGE"
# tour = image_name * ".tour"
# tour_theorique = "instances/tsp/tours/nikos-cat.tour"
# write_tour(tour,nodes_index_list, sum_of_weights(two_opt_cycle_graph))

# reconstruct_picture(tour, "instances/images/shuffled/nikos-cat.png", image_name * "-reconstruit.png",view = true)

shuffled_image_to_reconstruct("instances/tsp/instances/alaska-railroad.tsp","instances/images/shuffled/alaska-railroad.png","Train")