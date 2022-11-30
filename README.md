# Minimal Scheme implemented in Lua

> *Do It, Do It Again, and Again, and Again ...*  
> &emsp; — *The Little Schemer* by Friedmann and Felleisen

![Lisp cycles XKCD #297: "Those are your father's parentheses. Elegant weapons for a more... civilized age."](https://imgs.xkcd.com/comics/lisp_cycles.png)

(source <https://xkcd.com/297/>)

[Lua] is an interesting language. It is slightly older than JavaScript, though it never got even close to its popularity.
It has only [eight basic data types]. While lisps treat everything as lists, Lua treats everything as tables
(aka maps or dictionaries in other languages). An [array] is a table, [classes] are tables of methods relating to a table
of data values, etc. It is a multi-paradigm language, but like functional languages, it is [tail-call optimized].
It has some cool features, for example, when calling a function, the arguments that were [not provided] just default 
to `nil`. Also, a function can have multiple returns, but you can catch as many of them as you want. Calling
`x, y = foo()` will assign the first two returned values to `x` and `y` regardless of the actual number of returns,
whereas if `foo()` returned less than two values, they will just be `nil`.

To mimic Scheme's types, I re-used the basic types for booleans, numbers (as crazy as it sounds, Lua
[doesn't distinguish between number types]!), and strings. I use Lua's standard way of printing for
variables of those types, so strings are not quoted, and booleans are printed as `true` and `false` instead of `#t`
and `#f` (unlike Scheme, both `true` and `#t` will evaluate to boolean true). Symbols and lists were implemented using
custom types. Like old-school JavaScript, Lua's approach to object-oriented programming and [classes] is by using
prototypes. The symbol type got implemented as a `{ type = "symbol", name = <name> }` table.
Additionally, it has the `__eq` method for comparing symbols (are equal when having the same name) and `__tostring`
for pretty printing.

```lua
function Symbol(name)
    local symbol = { type = "symbol", name = name }
    setmetatable(symbol, {
        __eq = function(x, y)
            return x.name == y.name
        end,
        __tostring = function(o)
            return o.name
        end
    })
    return symbol
end
```

Scheme's lists, on other hand, are [linked lists] of the `{ type = "list", this = <head>, next = <tail> }` form. Where
`<head>` is what you would get from `(car list)` and `<tail>` from `(cdr list)`. By doing so (instead of using
Lua's arrays), we can efficiently detach lists head or tail, prepend it, etc which are common operations in lisps.

Environments are tables as well, `{ table = <records>, parent = <parent> }`, has `<records>` table of key-value
pairs for the local variable bindings, and `<parent>` is the reference to the enclosing environment (or `nil`).
Because Lua passes nearly everything [by references] we don't need to worry about the memory footprint here.
We can also rely on Lua's garbage collector to clean up not used environments for us.

The *[S-expressions]* are evaluated using the following rules

```lua
function eval.sexpr(sexpr, env)
    if isquoted(sexpr) then
        return sexpr.value
    elseif issymbol(sexpr) then
        return env:get(sexpr.name)
    elseif islist(sexpr) then
        return evallist(sexpr, env)
    else
        return sexpr
    end
end
```

Scheme\'s procedures are residing in a table of Lua functions. For example, `car` takes the first argument, a list,
evaluates it, and returns the first element of the resulting list. Because Lua is dynamically typed, we don't need
to worry about declaring the types here.

```lua
procedures["car"] = function(args, env)
    local list = eval.sexpr(args.this, env)
    return list.this
end
```

For a slightly more complicated example, `lambda` returns a function that evaluates its body within the local environment
created by binding the arguments passed to the function (`callargs`), with the keys given in the lambda declaration
(`vars`). The following code handles the Scheme's `((lambda (<vars>) <body>) <callargs>)` calls.

```lua
procedures["lambda"] = function(args, env)
    local vars = args.this
    local body = args.next
    return function(callargs, callenv)
        local localenv = env:branch()
        initlambda(vars, callargs, callenv, localenv)
        local _, result = eval.each(body, localenv)
        return result
    end
end
```

Interestingly, the resulting code is still over 1.6x faster than MIT Scheme for *The Little Schemer* examples.
While it is slower than Go or OCaml, it's very fast for an interpreted, dynamically typed language.


 [Lua]: http://www.lua.org
 [eight basic data types]: http://www.lua.org/pil/2.html
 [array]: http://www.lua.org/pil/11.1.html
 [classes]: http://www.lua.org/pil/16.html
 [tail-call optimized]: http://www.lua.org/pil/6.3.html
 [doesn't distinguish between number types]: http://www.lua.org/pil/2.3.html
 [linked lists]: http://www.lua.org/pil/11.3.html
 [by references]: https://stackoverflow.com/a/8431462/3986320
 [S-expressions]: https://en.wikipedia.org/wiki/S-expression
 [not provided]: http://www.lua.org/manual/5.4/manual.html#3.4
