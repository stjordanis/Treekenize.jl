# Copyright (c) 2013 Jasper den Ouden, under the MIT license, 
# see doc/mit.txt from the project directory.

# Parses just a subset, try to get as far as possible with this first.
module JuliaSubsetParse

using Treekenize

# --- end module stuff

export julia_subset_parse, sexpr_print

function julia_subset_parse(input)
    infix_set = ["=", "&&","||", "!","~","==","!=", ">",">=","<=","<",
                 "-","+", "/","*", "::", ":"]
                 
    add_infix(to) = (to[1],to[2],infix_set)
    return treekenize(input,
                      map(add_infix,
                          {("(",")"), ("[","]"), ("{","}"),
                           ("begin","end"),("function","end"),("if","end"),
                           ("type","end"),
                           ("typealias","\n"), ("@","\n"), ("#","\n")}),
                      add_infix(("\n","\n")), 10,1)
end

function sexpr_print(expr::StrExpr)
    if expr.head!="("
        print("($(expr.head)")
    else
        print("(open")
    end
    sexpr_print(expr.body, ",") 
    print(")")
end
function sexpr_print(array::Array, between) 
    for el in array
        print(between)
        sexpr_print(el)
    end
end
sexpr_print(array::Array) = sexpr_print(array, ",\n")
sexpr_print(other) = print(other)


end # module JuliaSubsetParse
