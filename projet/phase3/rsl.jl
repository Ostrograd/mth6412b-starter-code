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

function rsl(graph::Graph{Y,T},racine::Node{Y}) where {Y,T}

    tree, racine = prims_algorithm(graph, start_node_name = name(racine))
    nodes_list = parcours_preordre(tree, racine)

    cycle_tree = Tree("Cycle", [racine])
    last_node = racine
    for node in nodes(tree)[2:end]
        add_node!(cycle_tree, node)
    end
    
    for node in nodes_list[2:end]
        last_node.children = Vector{Int}[]
        add_child!(last_node,node)

        last_node = node
    end
    print(last(nodes_list))
    add_child!(last(nodes_list), racine)

    cycle = tree_to_graph(cycle_tree, racine)

    idx1 = index(racine)
    idx2 = parent_loc(racine)
    add_edge!(cycle, Edge(nodes(cycle)[parent_loc(racine)], nodes(cycle)[parent_loc(nodes_list[2])], adjacency_dict(graph)[idx1][idx2]))

    return cycle
end


show(cycle)

pwd()
graphe = graph_from_tsp("instances/stsp/swiss42.tsp","graphe")[1]

cycle = rsl(graphe, nodes(graphe)[1])

show(cycle)

poids = sum_of_weights(cycle)