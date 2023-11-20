"""
Ce code implémente l'algorithme de Kruskal qui crée un arbre de
recouvrement minimum à partir d'un graphe
"""


""" Tri par insertion une liste d'arêtes selon leur poids """
function insertion!(A::Vector{Edge{Int,Vector{Float64}}}) 
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
"""
function nodes_in_same_cconnexe(edge::Edge,CConnexes)
    node1, node2 = nodes(edge)
    for C in CConnexes
        if node1 in C.nodes
            if node2 in C.nodes
                return true
            else return false
            end
        end
    end

end
"""



""" Prend une arête [s_i,s_j] et la liste des composantes connexes en input et réunit les composantes connexes de s_i et s_j  """
function merge_trees!(tree, treenode1, treenode2, edge, graph)
    rank_union!(tree, treenode1, treenode2)

    add_edge!(graph,edge)
end 
"""
function merge_cconnexes!(edge, CConnexes)
    node1, node2 = nodes(edge)
    indice1, indice2 = 0, 0
    for i in eachindex(CConnexes)
        C = CConnexes[i]
        if node1 in nodes(C)  ##Assigne l'indice de la composante connexe du noeud 1
            indice1 = i     
        end
        if node2 in nodes(C)  ####Assigne l'indice de la composante connexe du noeud 2
            indice2 = i
        end
    end

    if indice1 != 0 && indice2 != 0
        append!(CConnexes[indice1].nodes, CConnexes[indice2].nodes)
        append!(CConnexes[indice1].edges, CConnexes[indice2].edges)
        add_edge!(CConnexes[indice1],edge)
        deleteat!(CConnexes, indice2)
    end

    return CConnexes
end
"""

# function kruskal(graphe::Graph)
#     A = insertion!(graphe.edges)   ##Tri les arêtes selon leur poids
#     CConnexes_list = []
#     i=1
#     for node in nodes(graphe)   ##Crée une composante connexe pour chaque noeud
#         push!(CConnexes_list,Comp_Connexe(string(i),Node{Vector{Float64}}[node],Edge{Int,Vector{Float64}}[]))
#     end
    
#     for edge in A
#         if length(CConnexes_list) == 1
#             break       ##On arrête lorsqu'il reste une seule composante connexe
#         end
#         if (nodes_in_same_cconnexe(edge,CConnexes_list)) != true    
#             CConnexes_list = Merge_CConnexes!(edge,CConnexes_list) ##Réunit les composantes connexes des deux noeuds
#         end
#     end
#     return CConnexes_list[1]
# end
""" Construit l'arbre de recouvrement minimum avec l'algorithme de Kruskal"""
function kruskal(graphe::Graph)
    edges_list = insertion!(graphe.edges)   ##Tri les arêtes selon leur poids
    kruskal_graph = Graph("Kruskal",nodes(graphe),Edge{Int,Vector{Float64}}[])
    #arbre_min = Tree{Int}("Arbre min", Vector{TreeNode}[])

    treenodes_list = Vector{TreeNode}()
    treenodes_names = []
    i=1
    for node in nodes(graphe)
        push!(treenodes_list, TreeNode(name(node), 0, nothing , Vector{Int}(), 0, i))
        push!(treenodes_names, name(node))
        #add_node!(arbre_min, TreeNode(name(node), 0, nothing , Vector{Int}(), 0, i))
        i+=1
    end
    print(treenodes_names)
    main_tree = Tree{Int}("Arbre", treenodes_list)
    for edge in edges_list 
        in_same, treenode1, treenode2 = nodes_in_same_cconnexe(edge, treenodes_list,treenodes_names, main_tree)
        if !in_same
            merge_trees!(main_tree,treenode1, treenode2, edge, kruskal_graph)
        end
    end
    return kruskal_graph
    
end