# NDPriorityQueues

This package provides a class for a non-deterministic priority queue. It allows to draw random items from the queue with a probability proportional to their priority.

Usage:
```julia
using NDPriorityQueues

pq = NDPriorityQueue{Int, Float64}()

enqueue!(pq, 1, 1.0)  # add item 1 with priority 1.0
enqueue!(pq, 2, 2.0)

pq[2] = 3.0  # change priority of item 2 to 3.0
pq[3] = 4.0  # add item 3 with priority 4.0

draw(pq)  # draw a random item from the queue (e.g. 3) without removing it

dequeue!(pq)  # remove and return a random item from the queue
dequeue_pair!(pq)  # remove and return a random item and its priority from the queue

pq[1]  # get priority of item 1

delete!(pq, 1)  # remove item 1 from the queue

pq = NDPriorityQueue{Int, Float64}(Dict(1 => 1.0, 2 => 2.0))  # create queue from dictionary

```
