include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
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

abstract type AbstractTree{T} end

mutable struct Tree{T} <: AbstractTree{T}
    name::String
    data::T
    parent:: Union{Nothing, Tree{T}}
    children::Vector{Tree{T}}
    rank::Real
end

"""Crée un arbre"""
function Tree(name::String, data::T) where {T}
  Tree(name, data, nothing , Vector{Tree{T}}(), 0)
end

"""renvois les données de l'arbre"""
data(tree::Tree) = tree.data

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
  if !isnothing(graph.parent) 
    remove_child!(graph.parent, graph)
  end
  graph.parent = parent
  add_child!(parent, graph)
  graph
end

"""change le rang de l'arbre"""
function change_rank!(graph::Tree{T}, rank::Real) where {T}
  rank = max(0, rank)
  graph.rank = rank
  graph
end

"""Trouve la racine de l'arbre"""
function find_root(tree::Tree{T}) where T
  #root is the only node without a parent
  if isnothing(parent(tree))
      return tree
  else
      return find_root(parent(tree))
  end
end



"""Affiche un arbre"""
function show(tree::AbstractTree)
  println("Node ", name(tree), " has  rank ", rank(tree), "and ", length(children(tree)), " children.")
  nodes_to_visit = copy(children(tree))
  println("listing of children : ")
  while length(nodes_to_visit) != 0
    node = popfirst!(nodes_to_visit)
    parent_node = parent(node)
    println("node_visited: ", name(node), "     \n its parent is ", name(parent_node), 
            "     \n its rank (or distance to parent) is ", rank(node))
    for child in children(node)
      println("child: ", name(child))
      push!(nodes_to_visit, child)
    end
  end
end

"""Convert un arbre en graphe"""
function tree_to_graph(tree::Tree{T}) where T
  graph = Graph(name(tree), Node{T}[], Edge{Float64, T}[])
  nodes_to_visit = copy(children(tree))
  while length(nodes_to_visit) != 0
    current_tree = popfirst!(nodes_to_visit)
    node = Node(name(current_tree), data(current_tree))
    parent_tree= parent(current_tree)
    for child in children(current_tree)
      push!(nodes_to_visit, child)
    end
    if !isnothing(parent_tree)
      parent_node = Node(name(parent_tree), data(parent_tree))
      distance = convert(Float64, rank(current_tree))
      edge = Edge(parent_node, node, distance)
      add_edge!(graph, edge)
    end
  end
  graph
end