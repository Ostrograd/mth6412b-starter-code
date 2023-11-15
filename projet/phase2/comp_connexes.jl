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

mutable struct TreeNode{T} <: AbstractNode{T}
  name::String
  data::T
  parent::Union{Int, Nothing}
  children::Vector{Int}
  rank :: Real
  index::Int
end


abstract type AbstractTree{T} end

mutable struct Tree{T} <: AbstractTree{T}
    name::String
    nodes::Vector{TreeNode{T}}
end

"""renvoie le nom de l'arbre"""
name(tree::Tree) = tree.name

"""Crée un noeud"""
function TreeNode(name::String, data::T) where {T}
  TreeNode(name, data, nothing , Vector{Int}(), 0, 0)
end




"""Ajoute un noeud à l'arbre"""
function add_node!(tree::Tree{T}, node::TreeNode{T}; parent::Union{TreeNode{T}, Nothing}=nothing) where {T}
  change_index!(node, length(tree.nodes)+1)
  if !isnothing(parent)
    add_child!(parent, node)
    node.parent = index(parent)
  end
  push!(tree.nodes, node)
  tree
end

"""renvoie les noeuds de l'arbre"""
nodes(tree::Tree) = tree.nodes


"""renvoie les indices les enfants du noeud"""
children_loc(node::TreeNode) = node.children

"""renvoie les enfants du noeud"""
function children(tree::Tree, node::TreeNode)
  children = Vector{TreeNode}()
  for child in children_loc(node)
    push!(children, tree.nodes[child])
  end
  return children
end

"""renvoie l'indice du noeud"""
index(node::TreeNode) = node.index

"""change l'indice du noeud"""
function change_index!(node::TreeNode, index::Int)
  node.index = index
  node
end

"""renvoie  le l'indice du parent du noeud"""
parent_loc(node::TreeNode) = node.parent

#parent(tree::Tree, node::TreeNode) = tree.nodes[parent_loc(node)]

"""renvoie le parent du"""
function parent(tree::Tree, node::TreeNode)
  if isnothing(parent_loc(node))
    return nothing
  else
    return tree.nodes[parent_loc(node)]
  end
end

"""renvoie le rang du noeud"""
rank(node::TreeNode) = node.rank

"""Montre le noeud"""
function show(tree:: Tree, node::TreeNode)
  println("Node ", name(node), " has  rank ", rank(node), " and ", length(children_loc(node)), " children.")
  if isnothing(parent(tree, node))
    println("It has no parent.")
  else
    println("Its parent is ", name(parent(tree, node)))
  end
  if length(children_loc(node)) == 0
    println("It has no children.")
  else
  println("Its children are: ")
  for child in children(tree, node)
    println("     ", name(child))
  end
end
end

"""Define un noeud comme enfant du noeud."""
function add_child!(parent::TreeNode, child::TreeNode)
  push!(parent.children, index(child))
  child.parent = index(parent)
  parent
end

"""enlever un efant d'un noeud."""
function remove_child!(parent::TreeNode, child::TreeNode) 
  if (index(child) in children_loc(parent)) != true
    throw(ValueError("L'élément ",name(child)," n'est pas un enfant de ",name(parent),". Il ne peut pas être supprimé de la liste des enfants."))
  end
  deleteat!(parent.children, findfirst(x -> x == index(child), parent.children))
  child.parent = nothing
  parent
end

"""change le parent d'un enfant"""
function change_parent!(tree::Tree, child::TreeNode, parent_node::TreeNode) 
  #Enleve l'enfant de son ancien parent
  if !isnothing(child.parent) 
    remove_child!(parent(tree, child), child)
  end
  #Define l'indice du parent
  child.parent = index(parent_node)
  add_child!(parent_node, child)
  child
end

"""change le rang du noeud"""
function change_rank!(node::TreeNode, rank::Real) 
  rank = max(0, rank)  ##Le rang ne peut pas être négatif
  node.rank = rank
  node
end

"""Trouve la racine de l'arbre"""
function find_root(tree::Tree, node::TreeNode) 
  #root is the only node without a parent
  if isnothing(parent(tree, node))
      return node
  else
      return find_root(tree, parent(tree, node))
  end
end

"""Trouve la racine de l'arbre. Cette fonction marche seulement si l'arbre est connexe"""
function find_root(tree::Tree) 
  return find_root(tree, tree.nodes[1])
end



# """Affiche un arbre"""
# function show(tree::AbstractTree)
#   println("Node ", name(tree), " has  rank ", rank(tree), " and ", length(children(tree)), " children.")
#   nodes_to_visit = copy(children(tree))
#   while length(nodes_to_visit) != 0
#     node = popfirst!(nodes_to_visit)
#     parent_node = parent(node)
#     println("node_visited: ", name(node), "     \n its parent is ", name(parent_node), 
#             "     \n its rank is ", rank(node))
#     if length(children(node)) != 0
#       println("   its children are: ")
#       for child in children(node)
#         println("     ", name(child))
#         push!(nodes_to_visit, child)
#       end
#     end
#   end
# end

"""Affiche un arbre"""
function show(tree::AbstractTree)
  for node in nodes(tree)
    show(tree, node)
  end
end

"""Convert un arbre en graphe"""
function tree_to_graph( tree::Tree{T}, root::TreeNode{T}) where T
  graph = Graph(name(tree), Node{T}[], Edge{Float64, T}[])
  nodes_to_visit = copy(children(tree, root))
  while length(nodes_to_visit) != 0
    current_tree = popfirst!(nodes_to_visit)
    node = Node(name(current_tree), data(current_tree))
    parent_tree= parent(tree, current_tree)
    for child in children(tree, current_tree)
      push!(nodes_to_visit, child)
    end
    if !isnothing(parent_tree)
      parent_node = Node(name(parent_tree), data(parent_tree))
      distance = convert(Float64, rank(current_tree))
      edge = Edge(parent_node, node, distance)
      add_edge!(graph, edge, safe=false)
    end
  end
  graph
end

#affiche la somme des poids des arretes d'un graphe
function sum_of_weights(graph::AbstractGraph{T}) where T
  sum = 0
  for edge in edges(graph)
      sum += weight(edge)
  end
  return sum
end