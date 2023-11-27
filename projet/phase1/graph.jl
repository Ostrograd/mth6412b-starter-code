import Base.show


"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T} end

"""Type representant un graphe comme un ensemble de noeuds.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    G = Graph("Ick", [node1, node2, node3])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct Graph{Y,T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{Y}}
  edges::Vector{Edge{T,Y}}
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::Graph{Y,T}, node::Node{Y}) where {Y,T}
  push!(graph.nodes, node)
  graph
end

"""Ajoute un noeud au graphe au index i."""
function add_node!(graph::Graph{Y,T}, node::Node{Y}, i::Int) where {Y,T}
  insert!(graph.nodes, i, node)
  graph
end

"""Enlever un noeud au graphe."""
function remove_node!(graph::Graph{Y,T}, node::Node{Y}) where {Y,T}
   index = findfirst(x -> x.name == node.name, graph.nodes)
  deleteat!(graph.nodes, index)
  return index
end

"""Donne l'index du noeud dans le graphe."""
function index_node(graph::Graph{Y,T}, node::Node{Y}) where {Y,T}
  index = findfirst(x -> x.name == node.name, graph.nodes)
  return index
end

"""Enlever tous les arretes qui contiennent un noeud."""
function remove_edges!(graph::Graph{Y,T}, node::Node{Y}) where {Y,T}
  graph.edges = filter(x -> x.node1.name != node.name && x.node2.name != node.name, graph.edges)
  graph
end

"""Ajoute une arête au graphe"""
function add_edge!(graph::Graph{Y,T}, edge::Edge{T,Y}; safe = true) where {Y,T}
  push!(graph.edges, edge)
  if !(edge.node1.name in nodes_names(graph))
    add_node!(graph, edge.node1)
    if safe
      @warn "Le noeud",edge.node1.name," n'était pas dans le graphe. Il a été ajouté."
    end
  end
  if !(edge.node2.name in nodes_names(graph))
    add_node!(graph, edge.node2)
    if safe
      @warn "Le noeud",edge.node2.name," n'était pas dans le graphe. Il a été ajouté."
    end
  end
  graph
end

"""Adds an edge to the graph, and changes the weight of the edge if it does not match the graphs edge"""
function add_edge!(graph::Graph{Y,T}, edge::Edge{X,Y}; safe = true) where {X, Y,T}
  new_edge = Edge(edge.node1, edge.node2, T(edge.weight))
  push!(graph.edges, new_edge)
  if !(edge.node1.name in nodes_names(graph))
    add_node!(graph, edge.node1)
    if safe
      @warn "Le noeud",edge.node1.name," n'était pas dans le graphe. Il a été ajouté."
    end
  end
  if !(edge.node2.name in nodes_names(graph))
    add_node!(graph, edge.node2)
    if safe
      @warn "Le noeud",edge.node2.name," n'était pas dans le graphe. Il a été ajouté."
    end
  end
  graph
end

# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name` et `nodes`.

"""Renvoie la liste des noms des noeud du graphe."""
function nodes_names(graph::AbstractGraph)
  nodes_names = []
  for node in graph.nodes
    push!(nodes_names,node.name)
  end
  nodes_names
end

"""Renvoie le nom du graphe."""
name(graph::AbstractGraph) = graph.name

"""Renvoie la liste des noeuds du graphe."""
nodes(graph::AbstractGraph) = graph.nodes

"""Renvoie la liste des arêtes du graphe."""
edges(graph::AbstractGraph) = graph.edges

"""Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""Renvoie le nombre d'arêtes du graphe."""
nb_edges(graph::AbstractGraph) = length(graph.edges)



"""Affiche un graphe"""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes.")
  for node in nodes(graph)
    show(node)
  end
  println("Graph ", name(graph), " has ", nb_edges(graph), " edges.")
  for edge in edges(graph)
    show(edge)
  end
end

#Returns the degrees of nodes in  a graph
function degree(graph::Graph)
  adjacency_list = adjacency_dict(graph)
  degrees = []
  for i in 1:length(nodes(graph))
      push!(degrees, length(keys(adjacency_list[i])))
  end
  return degrees
end

"""Verifi si un string est un nombre"""
function check_str2(a)
  return tryparse(Float64, a) !== nothing
end

function nodes_dictionnary(graph::Graph)
    nodes_dict = Dict()
  for (ind, node) in enumerate(nodes(graph))
    if check_str2(name(node))
    nodes_dict[parse(Int,name(node))] = data(node)
    else
      nodes_dict[ind] = data(node)
    end
  end
  return nodes_dict
end

function adjacency_list(graph::Graph)
  liste = []
  for k = 1 : length(nodes(graph))
    edge_list = Int[]
    push!(liste, edge_list)
  end
  for edge in graph.edges
    node1, node2 = nodes(edge)
    index1 = index_node(graph, node1)
    index2 = index_node(graph, node2)

    push!(liste[index1], index2)
    push!(liste[index2], index1)
  end
  return liste
end

#Functions that creates a 2d vector of the adjacency matrix
function get_adjacency_matrix(graph::Graph)
  adjacency_list = adjacency_dict(graph)
  adjacency_matrix = zeros(length(nodes(graph)), length(nodes(graph)))
  for i in 1:length(nodes(graph))
      for j in 1:length(nodes(graph))
          if haskey(adjacency_list[i], j)
              adjacency_matrix[i,j] = adjacency_list[i][j]
          else
              adjacency_matrix[i,j] = Inf
          end
      end
  end
  return adjacency_matrix
end
