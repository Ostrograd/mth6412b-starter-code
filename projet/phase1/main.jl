## Importations
include("node.jl")
include("edges.jl")
include("graph.jl")
include("read_stsp.jl")

##Code Principal

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
    show(graphe)
    return graphe, graphe_nodes
end

graphe, graphe_nodes = graph_from_tsp("instances\\stsp\\gr17.tsp","graphe1")


