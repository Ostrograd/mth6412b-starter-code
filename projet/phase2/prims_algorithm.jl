include("queue.jl")
include("comp_connexes.jl")


"""crée une liste d'adjacence a partir d'un graphe"""
function adjacency_dict( graph::Graph) 
    #Dictionaire de adjacence
    adj_dict = Dict()
    #Dictionaire de correspondance entre les noeuds et les items de la file de priorite
    correspondance_dict = Dict()
    #Chaque noeud est une clef du dictionaire de adjacence
    for (i, node) in enumerate(nodes(graph))
        adj_dict[i] = Dict()
        correspondance_dict[node] = i
    end
    #Ajoute les voisins de chaque noeud dans le dictionaire de adjacence
    for edge in edges(graph)
        node1, node2 = nodes(edge)
        idx1 = correspondance_dict[node1]
        idx2 = correspondance_dict[node2]
        adj_dict[idx1][idx2] = weight(edge)
        adj_dict[idx2][idx1] = weight(edge)
    end
    return adj_dict
end

"""Crée une file de priorite des arbres à partir d'un graphe. Le noeud de depart a une priorite de 0 et les autres ont une priorite de Inf"""
function prims_priority_queue(graph::Graph{Y,T}, start_node_name::String) where {Y,T}
    priority_queue = PriorityQueue{PriorityItem{TreeNode{Y}}}()
    tree = Tree(name(graph), Vector{TreeNode{Y}}())
    for node in nodes(graph)
        if name(node) == start_node_name
            blank_node = TreeNode(name(node), data(node))
            priority_item = PriorityItem( 0 , blank_node)
        else
            blank_node = TreeNode(name(node), data(node))
            priority_item = PriorityItem( Inf, blank_node)
        end
        add_node!(tree, blank_node)
        push!(priority_queue, priority_item)
    end
    return priority_queue, tree
end

"""Implementation de l'algorithme de Prim"""
function prims_algorithm(graph::Graph{Y,T}; start_node_name::Any = nothing) where {Y,T}
    #initialisation
    if isnothing(start_node_name)
        start_node_name = name(nodes(graph)[1])
    end
    #initialisation de la file de priorite et du dictionaire d'adjacence
    priority_queue, tree = prims_priority_queue(graph, start_node_name)
    adjacency_list = adjacency_dict(graph)
    #sauvegarde de la racine
    root = poplast!(priority_queue)
    priority_node = root
    #boucle principale
    while !is_empty(priority_queue)
        for  (neighbor_idx, edge_weight) in adjacency_list[index(data(priority_node))]
            #Met a jour la priorite du voisin si elle est dans le priority_que et elle est plus petite que la priorite actuelle
            for item in priority_queue.items
                #println("nodes(tree)[neighbor_idx] = ", nodes(tree)[neighbor_idx])
                if index(data(item)) == neighbor_idx
                    if  edge_weight < priority(item)
                        change_parent!(tree, nodes(tree)[neighbor_idx], data(priority_node))
                        change_rank!( nodes(tree)[neighbor_idx], edge_weight)
                        priority!(item, edge_weight)
                    end
                break
                end
            end
        end
        #prend le noeud avec la plus petite priorite
        priority_node = poplast!(priority_queue)         
    end
    return tree, data(root)
end