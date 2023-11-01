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

