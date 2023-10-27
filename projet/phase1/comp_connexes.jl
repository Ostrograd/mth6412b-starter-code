include("node.jl")
include("edges.jl")
include("graph.jl")
import Base.show


mutable struct Comp_Connexe{Y,T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{Y}}
  edges::Vector{Edge{T,Y}}
end

"""Ajoute un noeud à la composante connexe."""
function add_node!(graph::Comp_Connexe{Y,T}, node::Node{Y}) where {Y,T}
  push!(graph.nodes, node)
  graph
end

"""Ajoute une arête à la composante connexe"""
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



"""Affiche la composante connexe"""
function show(graph::Comp_Connexe)
  println("La composante connexe ", name(graph), " a ", nb_nodes(graph), " noeuds.")
  for node in nodes(graph)
    show(node)
  end
  println("La composante connexe ", name(graph), " a ", nb_edges(graph), " arretes.")
  for edge in edges(graph)
    show(edge)
  end
end


######################### Arbre : #############################


mutable struct Tree{Y,T} <: AbstractGraph{T}
    name::String
    nodes::Vector{Node{Y}}
    edges::Vector{Edge{T,Y}}
    root::Node{Y}
end

"""Renvoie la racine de la composante connexe"""
root(graph::Tree) = graph.root

"""Ajoute un noeud au graphe."""
function add_node!(graph::Tree{Y,T}, node::Node{Y}) where {Y,T}
  push!(graph.nodes, node)
  graph
end


"""Ajoute une arête au graphe"""
function add_edge!(graph::Tree{Y,T}, edge::Edge{T,Y}) where {Y,T}
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
##To do : Vérifier que add_edge! ne crée pas de cycle.
##          Ajouter les hauteurs pour les nodes