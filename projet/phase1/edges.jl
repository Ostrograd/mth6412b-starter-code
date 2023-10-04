import Base.show


"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{T} end

"""Type représentant les arêtes d'un graphe.

Exemple:

        edge = Edge( node1, node2, poids)
        

"""
mutable struct Edge{T,Y} <: AbstractEdge{T}
  node1::Node{Y}
  node2::Node{Y}
  weight::T
end

# on présume que toutes les arêtes dérivées de AbstractEdge
# posséderont des champs 'weight', 'node1' et 'node2'.

"""Renvoie le poids de l'arête."""
weight(edge::AbstractEdge) = edge.weight

"""Renvoie les deux noeuds de l'arête"""
nodes(edge::AbstractEdge) = edge.node1, edge.node2



"""Affiche un noeud."""
function show(edge::AbstractEdge)
  println("Arête de ", name(nodes(edge)[1]), " à ", name(nodes(edge)[2]), ", poids: ", weight(edge))
end
