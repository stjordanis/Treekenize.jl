
# Clean parser

## Goal
Intended to be a parser where the relation to the AST tree and the code is 
clear. (In Julia, the `Expr` objects tree.)

In order to be able to use homoiconicness of a language properly, it is useful
not to have gotchas in the syntax. This attempts to reach that by parsing a
language that consists of two elements:

* There are 'blocks' with a beginner and an ender. For instance in Julia:
  `(`-`)`,`[`-`]` and `{`-`}` but also `begin`-`end`, `function`-`end`, 
  `type`-`end`, and `@`,`typealias`,`const` and a new line.
  
* Further there is infix notation, with some order.

## Implementation
The implementation is much more flexible than that, a beginner-ender can change
the beginners and enders insider entirely.

## Problems/deviations for application to julia
For functions to work, 'nothing or just whitespace' would have to be a potential
infix symbol.

`if` would have to be able to deal with `else` and `elseif`, perhaps extend the
concept.

`"` needs to deal with escapes.

Other issues(`const`?)
