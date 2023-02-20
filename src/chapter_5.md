# Connection with fold

As we saw in previous chapters `flatMap` is a more general operation than `filter`. While having both of them yields some benefits, logic of `filter` can be implemented via `flatMap`. In this chapter we will draw another connection between `flatMap` and `fold`.

Let's revisit our previous problem of finding total price of collection of orders, and write down another solution there, which involves using `map` and `flatMap`.

```go
ordersPrices := flatMap(orders, func(o Order) []double {
  return map(o.items, func(i Item) double { return i.price })
})
```

To break it down, we first convert each item to it's price using `map`, then output is threaded through `flatMap` to produce final slice of prices for each order in initial collection. Each `map` output will produce a slice and `flatMap` will take care of flattening and concatenating all those slices into final list of prices. We can use then `fold` to compute cumulative value similar to what we did in a previous chapter.

We are going to use `fold` to do the same, starting with inner call to `map`. Checking `fold` function signature will give us some hints on how to approach this problem. Type that is named as `T` will be `Item`, type of our initial collection, and resulting type we want to build is slice of double `[]double`. Initial value that we will use is also straightforward, an empty slice `[]{}`. And all that is remaining to write an `agg` function that would build resulting value, concatenating each next item's price with the final result. As you might have guessed we will use `append`.

Let's look at the implementation:

```go
prices := fold(items, []{}, func(a []double, i Item) []double {
  return append(a, i.price)
})
```

Notice, here our aggregation function is acting on arguments of two different types, which is much more sophisticated than plain sum of two doubles we used in previous chapter. Defining separate types for aggregated value and collection item allows us this kind of flexibility and is also not possible within `reduce` definition we gave in last chapter.

To tackle the rest of the problem, we will use similar technique, now using `append` on slices instead of separate items.

```go
func (o Order) orderPrices []double {
  return fold(o.items, []{}, func(a []double, i Item) []double {
    return append(a, i.price)
  })
}

ordersPrices := fold(orders, []{}, func(res []double, o Order) []double {
  return append(res, o.orderPrices()...)
})
```

As we see, using `fold` is quite a bit more mouthful, since we need to provide those initial values explicitly as well as aggregation function definition is longer that in case of `flatMap`/`map` combo. But still we are able to show that `fold` is a more general operation than `flatMap`, in similar way that `flatMap` is more general than `map` and `filter`.
