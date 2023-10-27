include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")
include("Kruskal.jl")
include("comp_connexes.jl")
using(Test)

#Testing node.jl
noeud = Node("Kirk", "guitar")
@test name(noeud) == "Kirk"
@test data(noeud) == "guitar"

#Testing edges.jl
noeud1 = Node("Kirk", [21.])
noeud2 = Node("Spock", [22.])
arrete1 = Edge( noeud1, noeud2,1)
@test weight(arrete1) == 1
@test nodes(arrete1) == (noeud1, noeud2)

#Testing graph.jl
graphe = Graph("graphe1",Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])
@test nb_nodes(graphe) == 0
@test nb_edges(graphe) == 0
add_edge!(graphe,arrete1)
@test nb_nodes(graphe) == 2
@test nb_edges(graphe) == 1
node3 = Node("McCoy", [23.])
add_node!(graphe,node3)
@test nb_nodes(graphe) == 3
add_edge!(graphe,Edge(node3,noeud1,2))
@test nb_edges(graphe) == 2

