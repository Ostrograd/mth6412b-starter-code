include("../phase1/node.jl")
include("../phase1/edges.jl")
include("../phase1/graph.jl")
include("../phase2/comp_connexes.jl")
include("../phase2/Kruskal.jl")
include("../phase2/heuristics.jl")
include("../phase3/hk.jl")
include("../phase3/rsl.jl")
include("../phase4/two_opt.jl")
include("tools.jl")
using(Test)

#Fully connected graph with 7 edges
a = Node("a",[0., 0.3])
b = Node("b",[1.2, 0.1])
c = Node("c",[2.,.5])
d = Node("d",[2.1, 0.1])
e = Node("e",[-0.1, 0.1 ])
f = Node("f",[0.2, 0.3])
g = Node("g",[0.1, 0.2])
node_list = [a,b,c, d,e, f, g]
#Edges are fully connected
edge1 = Edge(a,b, 4.)
edge2 = Edge(a,c, 8.)
edge3 = Edge(a, d, 11.)
edge4 = Edge(a, e, 8.)
edge5 = Edge(a, f, 7.)
edge6 = Edge(a, g, 1.)
edge7 = Edge(b, c, 6.)
edge8 = Edge(b, d, 2.)
edge9 = Edge(b, e, 4.)
edge10 = Edge(b, f, 7.)
edge11 = Edge(b, g, 2.)
edge12 = Edge(c, d, 7.)
edge13 = Edge(c, e, 1.)
edge14 = Edge(c, f, 6.)
edge15 = Edge(c, g, 3.)
edge16 = Edge(d, e, 5.)
edge17 = Edge(d, f, 4.)
edge18 = Edge(d, g, 8.)
edge19 = Edge(e, f, 2.)
edge20 = Edge(e, g, 7.)
edge21 = Edge(f, g, 3.)
edge_list = [edge1, edge2, edge3, edge4, edge5, edge6,
                edge7, edge8, edge9, edge10, edge11,
                edge12, edge13, edge14, edge15, edge16,
                edge17, edge18, edge19, edge20, edge21]
#creates the graph
tsp_test2 = Graph("Test2",node_list,edge_list)

cycle, nodes_list = semi_optimal_rsl(tsp_test2,3)
@test sum_of_weights(cycle) >= 17
@test length(nodes_list) == 7
@test length(nodes(cycle)) == 7
tour_indexes = Vector{Int64}([])
for node in nodes_list
    push!(tour_indexes, index(node))
end
println("running two opt")
two_opt_cycle_graph, two_opt_cycle, two_opt_cost = run_two_opt(tsp_test2,cycle, tour_indexes)
@test two_opt_cost >= 17
@test length(two_opt_cycle) == 7
@test length(nodes(two_opt_cycle_graph)) == 7
@test length(edges(two_opt_cycle_graph)) == 7