include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase1/read_stsp.jl")
include("Kruskal.jl")
include("comp_connexes.jl")
include("heuristics.jl")
include("prims_algorithm.jl")
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


@test_throws Exception remove_child!(tree1,tree3)
@test parent(tree3) == tree2

remove_child!(tree1,tree2)
@test parent(tree2) == nothing
@test length(children(tree1)) == 0
change_rank!(tree1,-5)
@test rank(tree1) == 0
racine = find_root(tree3)
@test racine == tree2 


#Testing prims_algorithm.jl
graphe_test = Graph("Test",Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])
#Nodes 
nodea = Node("a",[0.])
nodeb = Node("b",[0.])
nodec = Node("c",[0.])
noded = Node("d",[0.])
edge1 = Edge(nodea,nodeb, 1)
edge2 = Edge(nodea,noded, 6)
edge3 = Edge(nodea, nodec, 3)
edge4 = Edge(nodec, noded, 5)
edge5 = Edge(nodec, nodeb, 10)
edge6 = Edge(nodeb, noded, 2)
edge_list = [edge1, edge2, edge3, edge4, edge5, edge6]
#Add the nodes and edges to the graph
for i in edge_list
    add_edge!(graphe_test, i, safe=false)
end
#Test the priority queue
#C should have a priority of 0
priority_queue = prims_priority_queue(graphe_test, "c")
for item in priority_queue.items
    if name(data(item)) == "c"
        @test priority(item) == 0
    else
        @test priority(item) == Inf
    end
end
#Test the adjacency list
adj_dict = adjacency_dict(graphe_test, priority_queue)
#A and B should be one away from one another
@test adj_dict[priority_queue.items[1]][priority_queue.items[2]] == 1
#testing Prim's 
p_tree = prims_algorithm(graphe_test, start_node_name="c")
@test name(p_tree) == "c"
#C should only have 1 child
@test length(children(p_tree)) == 1
@test sum_of_weights(tree_to_graph(p_tree)) == 6

