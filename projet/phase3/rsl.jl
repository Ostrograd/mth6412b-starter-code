include("../phase2/comp_connexes.jl")
include("../phase2/prims_algorithm.jl")
include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase1/read_stsp.jl")
include("../phase1/main.jl")
include("../phase2/queue.jl")
include("../phase2/heuristics.jl")
include("../phase2/Kruskal.jl")
include

""" Parcours un arbre en préordre et retourne la liste des noeuds dans l'ordre dans lequel ils ont été visités."""
function parcours_preordre(tree, racine)
    current_node = racine
    parcours_liste = []
    completed_nodes = []
    i = 1
    while true
        change = false
        if !(current_node in parcours_liste)
            push!(parcours_liste, current_node)
        end

        for child in children(tree, current_node)
            if !(child in parcours_liste)
                current_node = child
                change = true
                break
            end
        end

        if change == false
            push!(completed_nodes,current_node)
            if length(nodes(tree)) == length(completed_nodes)
                break
            end
            current_node = parent(tree, current_node)
        end

    end
    return parcours_liste
end

""" Applique l'algorithme RSL sur un graphe et retourne un nouveau graphe contenant une tournée """
function rsl(graph::Graph{Y,T},start_node::Node{Y}, method = "Prim") where {Y,T}

    if method == "Kruskal"
        tree, racine = kruskal(graph, start_node_name = name(start_node)) #Détermine un arbre de recouvrement minimum
    else
        tree, racine = prims_algorithm(graph, start_node_name = name(start_node)) #Détermine un arbre de recouvrement minimum
    end
    
    nodes_list = parcours_preordre(tree, racine) #Parcours l'arbre de recouvrement minimum
    cycle_tree = Tree("Cycle", TreeNode{Y}[])
    last_node = racine
    for node in nodes(tree)  #Construit un arbre contenant la tournée
        add_node!(cycle_tree, node)     
    end

    for node in nodes_list
        last_node.children = Vector{Int}[]
        add_child!(last_node,node)
        last_node = node
    end
    
    add_child!(last(nodes_list), racine)
    cycle = tree_to_graph(cycle_tree, racine)   #Transforme l'arbre en graphe
    idx1 = index(racine)    #Ajoute l'arête entre le dernier noeud et la racine
    idx2 = parent_loc(racine)
    add_edge!(cycle, Edge(nodes(cycle)[parent_loc(racine)], nodes(cycle)[parent_loc(nodes_list[2])], adjacency_dict(graph)[idx1][idx2]))

    return cycle
end


# #graphe = graph_from_tsp("instances/stsp/swiss42.tsp","graphe")[1]
# bays_29 = graph_from_tsp("instances/stsp/bays29.tsp","graphe")[1]


# cycle = rsl(bays_29, nodes(bays_29)[1], "Prims")


# # println("here are the degrees", degree(cycle))
# # #cycle = rsl(graphe, nodes(graphe)[1], "Prims")

# show(cycle)
# plot_graph(cycle)
# println("Sum of weights ", sum_of_weights(cycle))
# # #poids = sum_of_weights(cycle)