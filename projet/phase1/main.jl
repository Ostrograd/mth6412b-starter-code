
include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")





graph_nodes, graph_edges, edges_weight_brut = read_stsp("instances\\stsp\\swiss42.tsp")

graphe = Graph("graphe1",Node{Int}[],Edge{Int,Int}[])

for edge in edges_weight_brut
    node1 = Node(string(edge[1]),0)
    node2 = Node(string(edge[2]),0)
    edge_brut = Edge(node1,node2,parse(Int,edge[3]))

    add_edge!(graphe,edge_brut)
end