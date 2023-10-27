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
function NodesInSameCConnexe(edge::Edge,CConnexes)
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

""" Prend une arête [s_i,s_j] et la liste des composantes connexes en input et réunit les composantes connexes de s_i et s_j  """
function Merge_CConnexes!(edge, CConnexes)
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

""" Construit l'arbre de recouvrement minimum avec l'algorithme de Kruskal"""
function Kruskal(graphe::Graph)
    A = insertion!(graphe.edges)   ##Tri les arêtes selon leur poids
    CConnexes_list = []
    i=1
    for node in nodes(graphe)   ##Crée une composante connexe pour chaque noeud
        push!(CConnexes_list,Comp_Connexe(string(i),Node{Vector{Float64}}[node],Edge{Int,Vector{Float64}}[]))
    end
    
    for edge in A
        if length(CConnexes_list) == 1
            break       ##On arrête lorsqu'il reste une seule composante connexe
        end
        if (NodesInSameCConnexe(edge,CConnexes_list)) != true    
            CConnexes_list = Merge_CConnexes!(edge,CConnexes_list) ##Réunit les composantes connexes des deux noeuds
        end
    end
    return CConnexes_list[1]
end