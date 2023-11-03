include("comp_connexes.jl")



"""Trouve la racine d'un arbre """
function find_root(tree::Tree{T}) where T
  #root is the only node without a parent
  if isnothing(parent(tree))
      return tree
  else
      return find_root(parent(tree))
  end
end


"""Implementation du premier heuristic"""
function rank_union!(tree_1::Tree{T}, tree_2::Tree{T}) where T
    root_1 = find_root(tree_1)
    root_2 = find_root(tree_2)
    if rank(root_1) == rank(root_2)
      change_parent!(root_2, root_1)
      change_rank!(root_1, rank(root_1) + 1)
      return root_1
    elseif rank(root_1) > rank(root_2)
      change_parent!(root_2, root_1)
      return root_1
    else
      change_parent!(root_1, root_2)
      return root_2
    end
end

"""Implementation du deuxieme heuristic. La function modifie l'arbre et ses predesseceurs en place"""
function path_compression!(tree::Tree)
    #la racine est le seul noeud sans parent
    if isnothing(parent(tree))
        return tree
    else
        root =  path_compression!(parent(tree))
        change_parent!(tree, root)
        return root
    end
end