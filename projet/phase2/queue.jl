import Base.length, Base.push!, Base.popfirst!
import Base.show
import Base.isless, Base.==, Base.maximum, Base.minimum

"""Type abstrait dont d'autres types de files dériveront."""
abstract type AbstractQueue{T} end

"""Ajoute `item` à la fin de la file `s`."""
function push!(q::AbstractQueue{T}, item::T) where T
    push!(q.items, item)
    q
end

"""Retire et renvoie l'objet du début de la file."""
popfirst!(q::AbstractQueue) = popfirst!(q.items)

"""Indique si la file est vide."""
is_empty(q::AbstractQueue) = length(q.items) == 0

"""Donne le nombre d'éléments sur la file."""
length(q::AbstractQueue) = length(q.items)

"""Affiche une file."""
show(q::AbstractQueue) = show(q.items)

"""Type abstrait dont d'autres types d'éléments de file de priorité dériveront."""
abstract type AbstractPriorityItem{T} end

#PRIORITY QUEUE
"""Type représentant un élément de la file de priorité. Il contient:
 un élément de type T
 une priorité de type Int."""
mutable struct PriorityItem{T} <: AbstractPriorityItem{T} 
    priority::Real
    data::T
end

"""Crée un élément de la file de priorité."""
function PriorityItem(priority::Real, data::T) where T 
    PriorityItem{T}(max(0, priority), data)
end

"""Renvoie les données d'un élément de la file de priorité."""
data(p::PriorityItem) = p.data

"""Renvoie la priorité de un élément de la file de priorité."""
priority(p::PriorityItem) = p.priority

"""change la priorité de un élément de la file de priorité."""
function priority!(p::PriorityItem, priority::Real) 
    p.priority = max(0, priority)
    p

end
"""compare la priorité de deux éléments de la file de priorité."""
isless(p1::PriorityItem, p2::PriorityItem) = p1.priority < p2.priority

==(p1::PriorityItem, p2::PriorityItem) = p1.priority == p2.priority 

"""File de priorité."""
mutable struct PriorityQueue{T <: AbstractPriorityItem} <: AbstractQueue{T}
    items::Vector{T}
end

"""initialisation d'une file de priorité"""
PriorityQueue{T}() where T = PriorityQueue(T[])

"""Crée un vector de noms des éléments de la file de priorité."""
function names(q::PriorityQueue)
    names = []
    for item in q.items
        push!(names, item.data.name)
    end
    names
end

"""Renvoie les élements de la file de priorité."""
items(q::PriorityQueue) = q.items

maximum(q::AbstractQueue) = maximum(q.items)

minimum(q::AbstractQueue) = minimum(q.items)

"""Retire et renvoie l'élément ayant la plus haute priorité."""
function popfirst!(q::PriorityQueue)
    highest = maximum(q)
    idx = findall(x -> x == highest, q.items)[1]
    deleteat!(q.items, idx)
    highest
end

"""Retire et renvoie l'élément ayant la plus base priorité."""
function poplast!(q::PriorityQueue)
    lowest = minimum(q)
    idx = findall(x -> x == lowest, q.items)[1]
    deleteat!(q.items, idx)
    lowest
end

"""imprime une file de priorité."""
function show(q::PriorityQueue)
    for item in q.items
        println("item: $(item.data) priority: $(item.priority)")
    end
end

"""File de priorité avec une stratégie de priorité LIFO."""
function last_in_first_out_priority_queue(v:: Vector{T}) where T
    q = PriorityQueue{PriorityItem}()
    counter = 0
    for item in v
        priority_item = PriorityItem(counter, item)
        push!(q, priority_item)
        counter += 1
    end
    q
end
