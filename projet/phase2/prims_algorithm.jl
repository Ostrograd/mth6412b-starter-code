include("queue.jl")
include("comp_connexes.jl")

"""crée une liste d'adjacence a partir d'un graphe"""
function adjacency_dict( graph::Graph , priority_queue::PriorityQueue{PriorityItem{Tree{T}}}) where T
    #Dictionaire de adjacence
    adj_dict = Dict()
    #Dictionaire de correspondance entre les noeuds et les items de la file de priorite
    correspondance_dict = Dict()
    #Chaque noeud est une clef du dictionaire de adjacence
    for (node, priority_item) in zip(nodes(graph),priority_queue.items)
        adj_dict[priority_item] = Dict()
        correspondance_dict[node] = priority_item
    end
    #Ajoute les voisins de chaque noeud dans le dictionaire de adjacence
    for edge in edges(graph)
        node1, node2 = nodes(edge)
        prior_item1 = correspondance_dict[node1]
        prior_item2 = correspondance_dict[node2]
        adj_dict[prior_item1][prior_item2] = weight(edge)
        adj_dict[prior_item2][prior_item1] = weight(edge)
    end
    return adj_dict
end

"""Crée une file de priorite a partir d'un graphe. Le noeud de depart a une priorite de 0 et les autres ont une priorite de Inf"""
function prims_priority_queue(graph::Graph{Y,T}, start_node_name::String) where {Y,T}
    priority_queue = PriorityQueue{PriorityItem{Tree{Y}}}()
    for node in nodes(graph)
        if name(node) == start_node_name
            blank_tree = Tree(name(node), data(node))
            priority_item = PriorityItem( 0 , blank_tree)
        else
            blank_tree = Tree(name(node), data(node))
            priority_item = PriorityItem( Inf, blank_tree)
        end
        push!(priority_queue, priority_item)
    end
    return priority_queue
end

function prims_algorithm(graph::Graph{Y,T}; start_node_name::Any = nothing) where {Y,T}
    #initialisation
    if isnothing(start_node_name)
        start_node_name = name(nodes(graph)[1])
    end
    #initialisation de la file de priorite et du dictionaire d'adjacence
    priority_queue = prims_priority_queue(graph, start_node_name)
    adjacency_list = adjacency_dict(graph, priority_queue)
    #sauvegarde de la racine
    root = poplast!(priority_queue)
    priority_node = root
    #boucle principale
    while !is_empty(priority_queue)
        for  (neighbor, edge_weight) in adjacency_list[priority_node]
            for item in priority_queue.items
                if name(data(neighbor)) == name(data(item))
                    if  edge_weight < priority(neighbor)
                        change_parent!(data(neighbor), data(priority_node))
                        change_rank!(data(neighbor), edge_weight)
                        priority!(neighbor, edge_weight)
                    end
                break
                end
            end
        end
        priority_node = poplast!(priority_queue)         
    end
    return data(root)
end