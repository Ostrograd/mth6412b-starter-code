include("node.jl")
include("edges.jl")
include("graph.jl")
import Base.show


"""Type representant un composante connexe qui est un graphe comme un ensemble de noeuds.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    G = Graph("Ick", [node1, node2, node3])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct Comp_Connexe{Y,T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{Y}}
  edges::Vector{Edge{T,Y}}
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::Comp_Connexe{Y,T}, node::Node{Y}) where {Y,T}
  push!(graph.nodes, node)
  graph
end

"""Ajoute une arête au graphe"""
function add_edge!(graph::Comp_Connexe{Y,T}, edge::Edge{T,Y}) where {Y,T}
  push!(graph.edges, edge)
  if !(edge.node1.name in nodes_names(graph))
    add_node!(graph, edge.node1)
    @warn "Le noeud",edge.node1.name," n'était pas dans le graphe. Il a été ajouté."
  end
  if !(edge.node2.name in nodes_names(graph))
    add_node!(graph, edge.node2)
    @warn "Le noeud",edge.node2.name," n'était pas dans le graphe. Il a été ajouté."
  end
  graph
end



"""Affiche un graphe"""
function show(graph::Comp_Connexe)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes.")
  for node in nodes(graph)
    show(node)
  end
  println("Graph ", name(graph), " has ", nb_edges(graph), " edges.")
  for edge in edges(graph)
    show(edge)
  end
end


######################### Arbre : #############################

abstract type AbstractTree{T} end

mutable struct Tree{T} <: AbstractTree{T}
    name::String
    data::T
    parent:: Union{Nothing, Tree{T}}
    children::Vector{Tree{T}}
    rank::Int
end

"""Crée un arbre"""
function Tree(name::String, data::T) where {T}
  Tree(name, data, nothing , Vector{Tree{T}}(), 0)
end

"""renvoie le nom de l'arbre"""
name(tree::Tree) = tree.name

"""renvoie les enfants de l'arbre"""
children(tree::Tree) = tree.children

"""renvoie le parent de l'arbre"""
parent(tree::Tree) = tree.parent

"""renvoie le rang de l'arbre"""
rank(tree::Tree) = tree.rank

"""Renvoie le parent de l'arbre"""
root(graph::Tree) = graph.parent

"""Ajoute un noeud à l'arbre."""
function add_child!(graph::Tree{T}, child::Tree{T}) where {T}
  push!(graph.children, child)
  graph
end

"""enlever un noeud à l'arbre."""
function remove_child!(graph::Tree{T}, child::Tree{T}) where {T}
  deleteat!(graph.children, findfirst(x -> x == child, graph.children))
  graph
end

"""change le parent de l'arbre"""
function change_parent!(graph::Tree{T}, parent::Tree{T}) where {T}
  graph.parent = parent
  graph
end

"""change le rang de l'arbre"""
function change_rank!(graph::Tree{T}, rank::Int) where {T}
  rank = max(0, rank)
  graph.rank = rank
  graph
end

# """Ajoute une arête à l'arbre"""
# function add_edge!(graph::Tree{Y,T}, edge::Edge{T,Y}) where {Y,T}
#   if !(edge.node1.name in nodes_names(graph))
#     add_node!(graph, edge.node1)
#     @warn "Le noeud",edge.node1.name," n'était pas dans le graphe. Il a été ajouté."
#   elseif edge.node2.name in nodes_names(graph)
#     #adding edge will create a circuit, so we don't add it
#     @warn "L'arête ",edge," n'a pas été ajoutée car elle crée un circuit."
#     return graph
#   end
#   if !(edge.node2.name in nodes_names(graph))
#     add_node!(graph, edge.node2)
#     @warn "Le noeud",edge.node2.name," n'était pas dans le graphe. Il a été ajouté."
#   end
#   push!(graph.edges, edge)
#   graph
# end
##To do : Vérifier que add_edge! ne crée pas de cycle.
##          Ajouter les hauteurs pour les nodes

"""Affiche un arbre"""
function show(tree::Tree)
  println("Node ", name(tree), " has  rank ", rank(tree))
  nodes_to_visit = copy(children(tree))
  println("listing of children : ")
  while length(nodes_to_visit) != 0
    node = popfirst!(nodes_to_visit)
    parent_node = parent(node)
    println("node_visited:", name(node), " its parent is ", name(parent_node), " its rank is ", rank(node))
    for child in children(node)
      push!(nodes_to_visit, child)
    end
  end
end
