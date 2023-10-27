## Importations
include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")
include("comp_connexes.jl")
include("Kruskal.jl")

##Code Principal

###### PHASE 1 ######
function graph_from_tsp(path::String,name::String) 

    graphe_nodes, graph_edges, edges_weight_brut = read_stsp(path)

    graphe = Graph(name,Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])  #Création d'un graphe vide


    for i in range(1,length(graphe_nodes))
        node = Node(string(i),graphe_nodes[i])
        add_node!(graphe,node)
    end


    for edge in edges_weight_brut      ##Ajout des arêtes et des noeuds un par un
        node1 = graphe.nodes[edge[1]] 
        node2 = graphe.nodes[edge[2]]
        edge_brut = Edge(node1,node2,edge[3])
        add_edge!(graphe,edge_brut)
    end
    
    return graphe, graphe_nodes
end

graphe1, graphe1_nodes = graph_from_tsp("instances\\stsp\\bays29.tsp","graphe1")

##### PHASE 2 #####
graphe_test = Graph("Test",Node{Vector{Float64}}[],Edge{Int,Vector{Float64}}[])

#Nodes 
nodea = Node("a",[0.])
nodeb = Node("b",[0.])
nodec = Node("c",[0.])
noded = Node("d",[0.])
nodee = Node("e",[0.])
nodef = Node("f",[0.])
nodeg = Node("g",[0.])
nodeh = Node("h",[0.])
nodei = Node("i",[0.])
node_list = [nodea,nodeb,nodec, noded,nodee, nodef, 
                nodeg, nodeh, nodei]

#Edges
edge1 = Edge(nodea,nodeb, 4)
edge2 = Edge(nodea,nodeh, 8)
edge3 = Edge(nodeb, nodeh, 11)
edge4 = Edge(nodeb, nodec, 8)
edge5 = Edge(nodeh, nodei, 7)
edge6 = Edge(nodeh, nodeg, 1)
edge7 = Edge(nodeg, nodei, 6)
edge8 = Edge(nodeg, nodef, 2)
edge9 = Edge(nodec, nodef, 4)
edge10 = Edge(nodei, nodec, 2)
edge11 = Edge(nodef, nodee, 10)
edge12 = Edge(nodee, noded, 9)
edge13 = Edge(nodec,noded, 7)
edge14 = Edge(noded, nodef, 14)
edge_list = [edge1, edge2, edge3, edge4, edge5, edge6,
                edge7, edge8, edge9, edge10, edge11,
                edge12, edge13, edge14]

##Construction du graphe
for i in node_list
    add_node!(graphe_test,i)
end
for i in edge_list
    add_edge!(graphe_test, i)
end

#CConnexes = Kruskal(graphe_test)
##Test avec tsp
CConnexe = Kruskal(graphe1)
