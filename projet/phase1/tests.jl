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

#Testing Kruskal.jl
arrete2 = Edge(noeud2,node3,2)
arrete3 = Edge(noeud1,node3,3)
arretes_list = [arrete3,arrete2,arrete1]
@test insertion!(arretes_list) == [arrete1, arrete2, arrete3]
CConnexe1 = Comp_Connexe("1",Node{Vector{Float64}}[noeud1,noeud2], Edge{Int,Vector{Float64}}[arrete1])
CConnexe2 = Comp_Connexe("2", Node{Vector{Float64}}[node3], Edge{Int,Vector{Float64}}[])
CConnexes = [CConnexe1,CConnexe2]
@test NodesInSameCConnexe(arrete3, CConnexes) == false
Merge_CConnexes!(arrete3,CConnexes)
@test length(CConnexes) == 1