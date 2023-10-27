include("comp_connexes.jl")



"""Implementation du premier heuristic"""
function rank_union!(tree_1::Tree{T}, tree_2::Tree{T}) where T
    if rank(tree_1) == rank(tree_2)
      change_parent!(tree_2, tree_1)
      change_rank!(tree_1, rank(tree_1) + 1)
      return tree_1
    elseif rank(tree_1) > rank(tree_2)
      change_parent!(tree_2, tree_21)
        return tree_1
    else
      change_parent!(tree_1, tree_2)
        return tree_2
    end
end

"""Implementation du deuxieme heuristic. La function modifie l'arbre et ses predesseceurs en place"""
function path_compression!(tree::Tree{T})
    #la racine est le seul noeud sans parent
    if isnothing(parent(tree))
        return tree
    else
        root =  path_compression!(parent(tree))
        change_parent!(tree, root)
        return root
    end
end