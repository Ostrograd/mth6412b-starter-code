"""
Ce code implémente l'algorithme de Kruskal qui crée un arbre de
recouvrement minimum à partir d'un graphe
"""


""" Tri par insertion une liste d'arêtes selon leur poids """
function insertion!(A::Vector{Edge{Y,Vector{T}}}) where {Y,T}
    n = length(A)
    for j = 2 : n
        key = A[j].weight
        edge = A[j]
        i = j - 1
        while i > 0 && A[i].weight > key
            A[i+1] = A[i]
            i = i - 1
        end
        A[i+1] = edge
    end
    A
end



""" Vérifie si les deux noeud d'une arête donnée sont dans la même composante connexe """
function nodes_in_same_cconnexe(edge::Edge, treenodes_list, treenodes_names, tree)
    node1, node2 = nodes(edge)
    
    treenode1 = treenodes_list[findall(x->x == string(name(node1)),treenodes_names)][1]
    treenode2 = treenodes_list[findall(x->x == string(name(node2)),treenodes_names)][1]


    if find_root(tree, treenode1) == find_root(tree, treenode2)
        return true, treenode1, treenode2
    else
        return false, treenode1, treenode2
    end
end



""" Prend une arête [s_i,s_j] et la liste des composantes connexes en input et réunit les composantes connexes de s_i et s_j  """
function merge_trees!(tree, treenode1, treenode2, edge, graph)
    rank_union!(tree, treenode1, treenode2)

    add_edge!(graph,edge)
end 


""" Construit l'arbre de recouvrement minimum avec l'algorithme de Kruskal"""
function kruskal(graphe::Graph)
    edges_list = insertion!(graphe.edges)   ##Tri les arêtes selon leur poids
    kruskal_graph = Graph("Kruskal",nodes(graphe),Edge{Int,Vector{Float64}}[])
    
    treenodes_list = Vector{TreeNode}()
    treenodes_names = []
    i=1
    for node in nodes(graphe)
        push!(treenodes_list, TreeNode(name(node), 0, nothing , Vector{Int}(), 0, i))
        push!(treenodes_names, name(node))
        
        i+=1
    end
   
    main_tree = Tree{Int}("Arbre", treenodes_list)
    for edge in edges_list 
        in_same, treenode1, treenode2 = nodes_in_same_cconnexe(edge, treenodes_list,treenodes_names, main_tree)
        if !in_same
            merge_trees!(main_tree,treenode1, treenode2, edge, kruskal_graph)
        end
    end
    return kruskal_graph
    
end

"""Transforme un graphe en arbre """
function graph_to_tree(graph::Graph{Y,T} ,root::Node{Y}) where {Y,T}
    graph_nodes = nodes(graph)
    index_nodes = collect(1:length(graph_nodes))
    root_treenode = TreeNode{Int}(name(root),0,nothing, Vector{Int}[],0,1)

    arbre  = Tree{Int}("Arbre", Vector{TreeNode}[])
    treenodes_list = []

    push!(treenodes_list,root_treenode)
    add_node!(arbre, root_treenode)
    adj_dict = adjacency_dict(graph)
    idx1 = findfirst(x->x == root,graph_nodes)
    deleteat!(index_nodes, findfirst(x->x == idx1, index_nodes))

    nodes_list = [1]
    parent_list = [1]
    for ind in keys(adj_dict[idx1])
        push!(nodes_list, ind)
        push!(parent_list, idx1)
    end

    
   for (ind_child, ind_parent) in zip(nodes_list,parent_list)
        if ind_child == idx1
            continue
        end
        node = graph_nodes[ind_child]
        treenode = TreeNode{Int}(name(node),0,nothing,Vector{Int}[],adj_dict[ind_parent][ind_child],1)

        node_parent = graph_nodes[ind_parent]
        name_list = []
        for node in nodes(arbre)
            push!(name_list, name(node))
        end

        ind_treenode_parent = findfirst(x->x == name(node_parent), name_list)

        add_node!(arbre, treenode, parent = nodes(arbre)[ind_treenode_parent])

        for ind in keys(adj_dict[ind_child])
            if !(ind in nodes_list) && ind != 1
                push!(nodes_list, ind)
                push!(parent_list, ind_child)
            end
        end
    end

    return arbre, find_root(arbre)
end

