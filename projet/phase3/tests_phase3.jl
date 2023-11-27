include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase1/read_stsp.jl")
include("../phase2/comp_connexes.jl")
include("../phase1/main.jl")
include("../phase2/queue.jl")
include("../phase2/heuristics.jl")
include("../phase2/Kruskal.jl")
include("../phase2/prims_algorithm.jl")
include("../phase3/hk.jl")
using(Test)


nodea = Node("a",[0.])
nodeb = Node("b",[0.])
nodec = Node("c",[0.])
noded = Node("d",[0.])
nodee = Node("e",[0.])
node_list = [nodea,nodeb,nodec, noded,nodee]
#Edges are fully connected
edge1 = Edge(nodea,nodeb, 3.)
edge2 = Edge(nodea,nodec, 2.)
edge3 = Edge(nodea, noded, 11.)
edge4 = Edge(nodea, nodee, 9.)
edge5 = Edge(nodeb, nodec, 1.)
edge6 = Edge(nodeb, noded, 12.)
edge7 = Edge(nodeb, nodee, 6.)
edge8 = Edge(nodec, noded, 6.)
edge9 = Edge(nodec, nodee, 4.)
edge10 = Edge(noded, nodee, 7.)
edge_list = [edge1, edge2, edge3, edge4, edge5, edge6,
                edge7, edge8, edge9, edge10]

tsp_test = Graph("Test",node_list,edge_list)

#tests for hk.jl
#testing get_leaves
test_tree, root_test = prims_algorithm(tsp_test)
function leaf_test(test_tree)
    leaves = get_leaves(test_tree)
    for node in leaves
        @test name(node)=="b" || name(node) == "d" || name(node) == "e"
    end
end
leaf_test(test_tree)

#testing get_closest_leaves
tsp_test2 = Graph("Test", copy(node_list), copy(edge_list))
remove_edges!(tsp_test2, noded)
remove_node!(tsp_test2, noded)
test_tree2, root_test2 = prims_algorithm(tsp_test2)
leaves2 = get_leaves(test_tree2)
leaf_edges = get_closest_leaves(test_tree2, tsp_test, noded)
@test length(leaf_edges) == 2
for edge in leaf_edges
    @test name(nodes(edge)[2]) == "e" || name(nodes(edge)[2]) == "d"
    @test name(nodes(edge)[1]) == "d" || name(nodes(edge)[1]) == "b"
end

#testing find_one_tree
one_tree_dist, one_tree = find_one_tree(tsp_test, noded)
@test length(nodes(one_tree))==5

#testing update_edge_weights
tsp_test3 = deepcopy(tsp_test)
new_edge_weights = [0.1, 0.2, 0.3, -4, 5]
update_edge_weights!(tsp_test3, new_edge_weights)
ae_edge = edges(tsp_test3)[4]
@test weight(ae_edge) == 14.1

#Testing function 

total_distance, one_tree = lkh_subgradient(tsp_test, departure_node = noded, t_k_method = "1/k", stop_k = 1000000)
@test degree(one_tree) == [2,2,2,2,2]
@test total_distance == 28