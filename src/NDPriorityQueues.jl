module NDPriorityQueues

export NDPriorityQueue, draw
import DataStructures

abstract type TreeNode{K,V<:Number} end

mutable struct Node{K,V<:Number} <: TreeNode{K,V}
    priority::V
    left_size::Int
    right_size::Int
    parent::Union{Node{K,V},Nothing}
    left::TreeNode{K,V}
    right::TreeNode{K,V}
end

Base.show(io::IO, node::Node) =
    print(io, "Node($(node.priority), $(node.left_size), $(node.right_size), $(node.left), $(node.right))")

mutable struct Leaf{K,V<:Number} <: TreeNode{K,V}
    value::K
    priority::V
    parent::Union{Node{K,V},Nothing}
end

Base.show(io::IO, leaf::Leaf) = print(io, "Leaf($(leaf.value), $(leaf.priority))")

mutable struct NDPriorityQueue{K,V<:Number} <: AbstractDict{K,V}
    root::Union{Node{K,V},Leaf{K,V},Nothing}
    index::Dict{K,Leaf{K,V}}

    NDPriorityQueue{K,V}() where {K,V<:Number} = new{K,V}(nothing, Dict{K,Leaf{K,V}}())

    function NDPriorityQueue{K,V}(itr) where {K,V<:Number}
        pq = new{K,V}(nothing, Dict{K,Leaf{K,V}}())
        for (k, v) in itr
            pq[k] = v
        end
        pq
    end
end

using InteractiveUtils: methodswith

function not_iterator_of_pairs(kv)
    return any(x -> isempty(methodswith(typeof(kv), x, true)), [iterate]) ||
           any(x -> !isa(x, Union{Tuple,Pair}), kv) ||
           !(eltype(kv) <: Union{Tuple,Pair})
end

function NDPriorityQueue(itr)
    if not_iterator_of_pairs(itr)
        throw(ArgumentError("PriorityQueue(itr): itr needs to be an iterator of tuples or pairs"))
    end
    try
        _priority_queue_with_eltype(itr, eltype(itr))
    catch e
        rethrow(e)
    end
end

_priority_queue_with_eltype(ps, ::Type{Pair{K,V}}) where {K,V} = NDPriorityQueue{K,V}(ps)
_priority_queue_with_eltype(kv, ::Type{Tuple{K,V}}) where {K,V} = NDPriorityQueue{K,V}(kv)

Base.show(io::IO, pq::NDPriorityQueue) = print(io, "NDPriorityQueue($(pq.root), $(pq.index))")

Base.length(pq::NDPriorityQueue) = length(pq.index)
Base.isempty(pq::NDPriorityQueue) = isempty(pq.index)
Base.haskey(pq::NDPriorityQueue, k) = haskey(pq.index, k)

Base.getindex(pq::NDPriorityQueue, k) = pq.index[k].priority

function Base.setindex!(pq::NDPriorityQueue, v, k)
    if haskey(pq.index, k)
        if pq.index[k].priority != v
            pq.index[k].priority = v
            _push_priority_up(pq.index[k])
        end
    else
        DataStructures.enqueue!(pq, k, v)
    end
end

function _enqueue!(pq::NDPriorityQueue, node::Nothing, k, v)
    leaf = Leaf(k, v, nothing)
    pq.index[k] = leaf
    return leaf
end

function _enqueue!(pq::NDPriorityQueue, node::Leaf, k, v)
    leaf = Leaf(k, v, nothing)
    new_node = Node(v + node.priority, 1, 1, node.parent, node, leaf)
    node.parent = new_node
    leaf.parent = new_node

    pq.index[k] = leaf
    return new_node
end

function _enqueue!(pq::NDPriorityQueue, node::Node, k, v)
    if node.left_size <= node.right_size
        new_node = _enqueue!(pq, node.left, k, v)
        node.left = new_node
        node.left_size += 1
    else
        new_node = _enqueue!(pq, node.right, k, v)
        node.right = new_node
        node.right_size += 1
    end

    node.priority += v
    return node
end

function DataStructures.enqueue!(pq::NDPriorityQueue, k, v)
    if haskey(pq.index, k)
        throw(ArgumentError("enqueue!(pq, k, v): pq already has key k"))
    end
    pq.root = _enqueue!(pq, pq.root, k, v)
end

function _push_priority_up(node::Leaf)
    if !isnothing(node.parent)
        _push_priority_up(node.parent)
    end
end

function _push_priority_up(node::Node)
    new_priority = node.left.priority + node.right.priority
    if new_priority != node.priority
        node.priority = new_priority
        if !isnothing(node.parent)
            _push_priority_up(node.parent)
        end
    end
end

function _draw(node::Leaf, draw_value)
    return node
end

function _draw(node::Node, draw_value)
    if draw_value <= node.left.priority
        return _draw(node.left, draw_value)
    else
        return _draw(node.right, draw_value - node.left.priority)
    end
end

function draw(pq::NDPriorityQueue)
    if isempty(pq)
        throw(ArgumentError("draw(pq): pq is empty"))
    end
    if length(pq) == 1
        return pq.root.value
    end
    draw_value = rand() * pq.root.priority
    _draw(pq.root, draw_value).value
end

function Base.delete!(pq::NDPriorityQueue, k)
    if !haskey(pq.index, k)
        throw(ArgumentError("delete!(pq, k): pq does not have key k"))
    end

    if length(pq) == 1
        pq.root = nothing
    else
        leaf = pq.index[k]
        if leaf.parent.left == leaf
            other = leaf.parent.right
        else
            other = leaf.parent.left
        end
        if isnothing(leaf.parent.parent)
            pq.root = other
            other.parent = nothing
        else
            if leaf.parent.parent.left == leaf.parent
                leaf.parent.parent.left = other
            else
                leaf.parent.parent.right = other
            end
            other.parent = leaf.parent.parent
        end
        _push_priority_up(other)
    end
    delete!(pq.index, k)
    return pq
end

function DataStructures.dequeue!(pq::NDPriorityQueue)
    k = draw(pq)
    delete!(pq, k)
    return k
end

function DataStructures.dequeue_pair!(pq::NDPriorityQueue)
    k = draw(pq)
    v = pq.index[k].priority
    delete!(pq, k)
    return k, v
end

function Base.empty!(pq::NDPriorityQueue)
    pq.root = nothing
    empty!(pq.index)
    return pq
end

function Base.keys(pq::NDPriorityQueue)
    return keys(pq.index)
end

function Base.values(pq::NDPriorityQueue)
    return (v.priority for v in values(pq.index))
end

function Base.iterate(pq::NDPriorityQueue)
    (k, leaf), state = iterate(pq.index)
    return (k, leaf.priority), state
end

function Base.iterate(pq::NDPriorityQueue, state)
    (k, leaf), state = iterate(pq.index, state)
    return (k, leaf.priority), state
end

end # module NDPriorityQueues
