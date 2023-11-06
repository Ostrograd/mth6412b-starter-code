include("comp_connexes.jl")



"""Implementation du premier heuristic"""
function rank_union!(tree::Tree, node1::TreeNode, node2::TreeNode) 
    root1 = find_root(tree, node1)
    root2 = find_root(tree, node2)
    if root1 == root2
      warning("Les deux noeuds sont deja dans le meme arbre")
      return root1
    else
    if rank(root1) == rank(root2)
      change_parent!(tree, root2, root1)
      change_rank!(root1, rank(root1) + 1)
      return root1
    elseif rank(root1) > rank(root2)
      change_parent!(tree, root2, root1)
      return root1
    else
      change_parent!(tree, root1, root2)
      return root2
    end
  end
end

"""Implementation du deuxieme heuristic. La function modifie l'arbre et ses predesseceurs en place"""
function path_compression!(tree::Tree, node::TreeNode)
    #la racine est le seul noeud sans parent
    if isnothing(parent_loc(node))
        return node
    else
        root =  path_compression!(tree, parent(tree,node))
        change_parent!(tree, node, root)
        return root
    end
end