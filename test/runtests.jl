using Test
using NDPriorityQueues
using DataStructures

@testset "Test" begin
    pq = NDPriorityQueue([(1, 1)])
    pq[2] = 2
    enqueue!(pq, 3, 3)
    @info pq
    @test pq[2] == 2
    pq[2] = 4
    @info pq
    @test pq[2] == 4
    @test length(pq) == 3
    counter = Dict{Int,Int}()
    for _ in 1:100
        v = draw(pq)
        if haskey(counter, v)
            counter[v] += 1
        else
            counter[v] = 1
        end
    end
    @info counter
    delete!(pq, 2)
    @info pq
    pq[2] = 4
    @info pq
    delete!(pq, 2)
    @info pq
end
