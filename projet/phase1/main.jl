include("graph.jl")
include("edges.jl")
include("node.jl")


node1 = Node("1",3)
node2 = Node("2",3)

edge = Edge(3,node1,node2)

show(edge)