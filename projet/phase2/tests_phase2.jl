include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase1/read_stsp.jl")
include("Kruskal.jl")
include("comp_connexes.jl")
include("heuristics.jl")
using(Test)


noeud1 = Node("Kirk", [21.])
noeud2 = Node("Spock", [22.])
node3 = Node("McCoy", [23.])
arrete1 = Edge( noeud1, noeud2,1)
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

#Testing heuristics.jl
tree1 = Tree("1",0)
tree2 = Tree("2",0)
tree3 = Tree("3",0)
change_rank!(tree3,1)
@test rank(tree3) == 1
rank_union!(tree1,tree2)
@test rank(tree1) == 1
rank_union!(tree2,tree3)
@test rank(tree2)==0
@test rank(tree1)==2
@test rank(tree3)==1

tree4 = Tree("4",0)
tree5 = Tree("5",0)
tree6 = Tree("6",0)
change_rank!(tree6,1)
rank_union!(tree4,tree5)
rank_union!(tree6,tree4)
@test parent(tree4) == tree6
rank_union!(tree1,tree4)
@test parent(tree5) == tree4
@test find_root(tree5) == tree1
path_compression!(tree5)
@test parent(tree5) == tree1
@test parent(tree4) == tree1

#Testing comp_connexes.jl
tree1 = Tree("1",0)
tree2 = Tree("2",0)
tree3 = Tree("3",0)

add_child!(tree1,tree2)
@test length(children(tree1)) == 1
add_child!(tree2,tree3)

e = try 
    remove_child!(tree1,tree3)
catch e
return e
end 
@test e isa Exception
@test parent(tree3) == tree2

remove_child!(tree1,tree2)
@test parent(tree2) == nothing
@test length(children(tree1)) == 0
change_rank!(tree1,-5)
@test rank(tree1) == 0
racine = find_root(tree3)
@test racine == tree2 