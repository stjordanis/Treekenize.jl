
# Clean parser

## Goal
Intended to be a parser where the relation to the AST tree and the code is 
clear. (In Julia, the `Expr` objects tree.)

In order to be able to use homoiconicness of a language properly, it is useful
not to have gotchas in the syntax. This attempts to reach that by parsing a
language that consists of two elements:

* There are 'blocks' with a beginner and an ender. For instance in Julia:
  `(`-`)`,`[`-`]` and `{`-`}` but also `begin`-`end`, `function`-`end`, 
  `type`-`end`, and `@`,`typealias`,`const` and a new line.(But Julia has 
  
* Further there is infix notation, with some order.

Actually it is not just for homoiconicness, the relation between the AST-tree
and the code is also a matter of sanity.

## Implementation
The implementation is much more flexible than that, it can change what are the
beginners and enders as indicated by one. But only because it can, this is not
necessarily a smart thing to do.


