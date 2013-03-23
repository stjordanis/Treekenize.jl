# Copyright (c) 2013 Jasper den Ouden, under the MIT license, 
# see doc/mit.txt from the project directory.

module Treekenize

import Base.readline

export treekenize, StrExpr #Function for making trees itself.
export none_incorrect
#Each element needs these to know what to do.
export head_expr, head_begin,head_end,head_infix, head_seeker

#Some extra transformations.(might move to other module)
#export infix_syms, combine_heads,remove_heads, remove_heads_1

export ConvenientStream

# --- end module stuff

type ConvenientStream #TODO not quite the right place to put this.
    stream::IOStream
    line::String
    line_n::Int64
end
ConvenientStream(stream::IOStream) = ConvenientStream(stream,"",int64(0))
#Pass on @with duties.
no_longer_with(cs::ConvenientStream) = no_longer_with(cs.stream)

function forward(cs::ConvenientStream, n::Integer)
#    print("|",cs.line[1:n])
    cs.line = cs.line[n:]
end
function readline(cs::ConvenientStream)
    cs.line_n += 1
    add_line = readline(cs.stream)
#    print(add_line, "|")
    cs.line = "$(cs.line)$add_line"
end

treekenize(stream::ConvenientStream, seeker::Nothing, end_str,
           limit_n::Integer, max_len::Integer) = end_str
function treekenize(stream::ConvenientStream, seeker::Function, end_str,
                    limit_n::Integer, max_len::Integer)
    new_seeker = seeker(stream,end_str)
    return treekenize(stream, new_seeker, head_end(new_seeker),
                      limit_n,max_len)
end

type IncorrectEnd
    initial_n::Int64 #Where it started.
    incorrect_n::Int64 #Where it ended with an incorrect ending symbol.
    
    correct_end
    got
end

#Turns a stream into a tree of stuff.
# `stream`  is the input stream
# `which`   is two arrays: 
#           elements of the first indicate(extractable with functions-):
#              `head_expr`, produces an 'expression' from a list.
#              `head_begin` what string starts it.
#              `head_end`   what end the expression will have.
#           the second is simply an array of disallowed strings.
# `end_str`      String that ends the current tree.
# `try_cnt`      Max number of attempts reading a line.
# `longest_len`  Longest word that begins/ends.
function treekenize(stream::ConvenientStream, which::(Array,Array),
                    end_str,
                    try_cnt::Integer, longest_len::Integer)
    seeker,not_incorrect = which
    list = {}
    n=0
    initial_n = stream.line_n
    readline(stream)
    
    function first_last_search(in_str, search_str)
        range = search(in_str, search_str)
        return first(range),last(range)+1
    end
    
    while n< try_cnt
        pick = nothing
        min_s = typemax(Int64)
        min_e = 0
        
        search_str = stream.line
        for el in seeker
            s,e = first_last_search(search_str, head_begin(el))
            if s!=0 && s< min_s
                pick = el
                min_s = s
                min_e = e
                if min_s + longest_len < length(search_str)
                    search_str =  search_str[1:min_s + longest_len]
                end
            end
        end
        s,e = first_last_search(search_str, end_str)
        search_str = search_str[1:s-1] #Warning about this guy.
        assert(s==0 || s<e)
      #Look for enders that dont match the begin.
      # (Depending on input some may be allowed)
        for el in not_incorrect
            s2,e2 = first_last_search(search_str, el)
            #Shouldnt be inside subtree.
            if s2!=0 && min_e!=0 && s2<min_s 
                throw(IncorrectEnd(initial_n, stream.line_n, end_str, el))
            end
        end
        
        if s!=0 && s<min_s #Ended before some subtree starting symbol.
            n=0
            if s>1
                assert( length(search_str) == s-1 )
                push!(list, search_str) #[1:s-1] (already done)
            end
            forward(stream, e)
            return list #Go up a level.
        elseif pick==nothing #got nothing, fetch some more.
            n+=1
            readline(stream)
        else #Got new branch.
            n=0
            if min_s>1
                push!(list, stream.line[1:min_s-1]) #Push what is here.
            end
            forward(stream, min_e)
           #Push branch.
            push!(list, head_expr(pick,
                                  treekenize(stream, head_seeker(which,pick),
                                             head_end(pick), 
                                             try_cnt, longest_len)))
        end
    end
    #TODO failed to end everything, this is potentially an error!
    # Problem is that i dont see a good way to check if it is eof.. (no mention)
    return list
end

#Makes the ConvenientStream for you.
treekenize(stream::IOStream, which::(Array,Array), end_str,
           try_cnt::Integer, longest_len::Integer) = 
    treekenize(ConvenientStream(stream), which, end_str, try_cnt,longest_len)
    
#(this version:)not_incorrect defaults to not checking anything.
treekenize{T}(thing::T, seeker::Array, end_str, 
              try_cnt::Integer, longest_len::Integer) =
    treekenize(thing, (seeker,{}), end_str, try_cnt,longest_len)

#If _all_ the given seekers may not be present incorrectly, this tries to
# make the list to detect it.
function none_incorrect(seeker::Array)
    list = {}
    for el in seeker
        if isa(el,Tuple) && length(el)>=2 && isa(el[2],String)
            push!(list, el[2])
        end
    end
    return list
end

type StrExpr #Structure for default AST tree.
    head::String
    body::Array
end

#Head is defaultly just the begin.
head_expr{T}(el::T, list::Array) = StrExpr(head_begin(el), list)

#The (String,String);(beginner,ender) seeker;
head_begin(el::(String,String))      = el[1]
head_end(el::(String,String))        = el[2]
head_infix(el::(String,String))      = Array(String,0) #No infix notation.
head_seeker(got,el::(String,String)) = got #Just keeps going with the same seeker.

#The (String,String,Array{String,1}); (beginner,ender, infix order)
typealias BEI (String,String,Array{String,1}) #Convenience.
head_begin(el::BEI)      = el[1]
head_end(el::BEI)        = el[2]
head_infix(el::BEI)      = el[3]
head_seeker(got,el::BEI) = got #Just keeps going with the same seeker.

end #module Treekenize