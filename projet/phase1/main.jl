## Importations
include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")

##Code Principal

graph_nodes, graph_edges, edges_weight_brut = read_stsp("instances\\stsp\\swiss42.tsp")

graphe = Graph("graphe1",Node{Int}[],Edge{Int,Int}[])  #Création d'un graphe vide

for edge in edges_weight_brut      ##Ajout des arêtes et des noeuds un par un
    node1 = Node(string(edge[1]),0)
    node2 = Node(string(edge[2]),0)
    edge_brut = Edge(node1,node2,edge[3])

    add_edge!(graphe,edge_brut)
end