# Copyright (c) 2013 Jasper den Ouden, under the MIT license, 
# see doc/mit.txt from the project directory.

using Treekenize

#Generates a random tree into stdout and returns the same list for later comparison.
function rnd_tree(to_stream::IOStream, p::Number,  depth::Integer,max_len::Integer, begin_end)
    list = {}
    if depth<0
        return {}
    end
    for i = 1:rand(1:max_len)
        if rand() < p #deepen
            j = rand(1:length(begin_end)) #Random 'parentheses'.
            b,e = begin_end[j]
            write(to_stream, b)
            push!(list, rnd_tree(to_stream,p, depth-1,max_len,begin_end))
            write(to_stream, e)
        else 
            x = rand()
            push!(list,x)
            write(to_stream, "$x ") #Just spaced out random numbers.
            for i = 1:rand(1:10)
                write(to_stream, " ")
            end
        end
    end
    return list
end

function rnd_tree(p::Number,  depth::Integer,max_len::Integer, begin_end)
    stream = memio()
    tree = rnd_tree(stream, p,depth,max_len, begin_end)
    write(stream, ";\n");
    seek(stream,0) #Back to the beginning.
    println(readall(stream))
    println(tree)
end

function test_treekenize(p::Number,  depth::Integer,max_len::Integer, 
                         begin_end, max_be_len::Integer)
    stream = memio()
    tree = rnd_tree(stream, p,depth,max_len, begin_end)
    
    write(stream, ";\n");
    seek(stream,0) #Back to the beginning.
    read_tree = treekenize(stream, (begin_end, none_incorrect(begin_end)),
                           ("top",";\n"),10, max_be_len)
    
    compare_tree(tree, compare::StrExpr) = compare_tree(tree, compare.body)
    function compare_tree(tree, compare)
        list = {}
        for el in compare
            if isa(el, String)
                for sel in split(el," ")
                    if sel!=""
                        push!(list, parsefloat(sel))
                    end
                end
            else
                push!(list, el)
            end
        end
        #ignore compare(hmm maybe that should exist..)
        assert(length(tree)==length(list), (tree,list))
        for i = 1:length(tree)
            if isa(list[i], Number)
                assert( tree[i]==list[i] )
            else
                compare_tree(tree[i], list[i])
            end
        end
    end
    compare_tree(tree, read_tree)
end

#TODO insert incorrectly placed ending/beginning parentheses and see if 
# the checker finds them at the right spots.

function test(cnt::Integer)
    for n = 1:cnt #TODO may want to test a larger variation of beginnings and ends.
        test_treekenize(0.4, 4,2, {("(",")"), ("begin","end"),
                                   ("[","]")},4)
    end
end

#test(100)