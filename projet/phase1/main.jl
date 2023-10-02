
include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")

node1 = Node("1",3)
node2 = Node("2",3)

edge = Edge(3,node1,node2)

show(edge)

graphe = Graph("Graphe1", Node{Int}[], Edge{Int,Int}[])

add_edge!(graphe,edge)

show(graphe)

read_stsp("instances\\stsp\\gr17.tsp")