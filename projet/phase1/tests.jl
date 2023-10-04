include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")
using(Test)

#Testing node.jl
noeud = Node("Kirk", "guitar")
@test name(noeud) == "Kirk"
@test data(noeud) == "guitar"

#Testing edges.jl
noeud1 = Node("Kirk", "guitar")
noeud2 = Node("Spock", "bass")
arrete = Edge( noeud1, noeud2,1)
@test weight(arrete) == 1
@test nodes(arrete) == (noeud1, noeud2)

#Testing graph.jl
graphe = Graph("graphe1",Node{String}[],Edge{Int,String}[])
@test nb_nodes(graphe) == 0
@test nb_edges(graphe) == 0
add_edge!(graphe,arrete)
@test nb_nodes(graphe) == 2
@test nb_edges(graphe) == 1
node3 = Node("McCoy", "drums")
add_node!(graphe,node3)
@test nb_nodes(graphe) == 3
add_edge!(graphe,Edge(node3,noeud1,2))
@test nb_edges(graphe) == 2