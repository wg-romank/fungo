# Summing it up with fold/reduce

In this chapter we will look into aggregations. One of the common tasks we might encounter working within the data model we defined so far is finding cumulative values. Like given set of order what is the total goods value associated with them? To approach this problem let's first modify our `Item` definition by adding a new field there - `price`.

```go
type Item {
  price double
}
```

In order to compute total order value we need to get price of each item in that order. Being familiar with `flatMap` primitive, we might want to use it here given slice of orders to get a slice of items prices then sum them up. Which is a valid approach, however we can actually define an operation that would allow us to do those kind of aggregations in more general way.

Let's look at the signature first.

```go
func fold[T any, U any](ts []T, initial U, agg func(U, T) U) U
```

We see that this function takes two type parameters `T` for type of original collection, which would be `Order` in our example. And `U` which is the type of aggregated value, which would be `double` since `Item`'s `price` field is defined as `double`.

As for actual input values we have the `ts` - expected initial slice we will do aggregation on, `initial` - the initial value of aggregator (which will be returned in case input collection `ts` is empty), and `agg` the function that would perform aggregation.

Let's look at the implementation:

```go
func fold(ts []T, initial U, agg func(U, T) U) U {
   res := initial
   for _, t := ts {
     res = agg(res, t)
   }
   return res
}
```

`agg` is called repeatedly on the results of previous result of `agg` and next item in collection. First `agg` is called on initial value and first element of the collection, in case collection is empty - initial value is returned.


In order to compute cumulative price associated with list of orders we would call `fold` like follows:

```go
func (o Order) totalPrice double {
  return fold(o.items, 0.0, func(p double, i Item) double { return p + i })
}

totalPrice := fold(orders, 0.0, func(p double, o Order) double {
  return p + o.totalPrice
})
```

Notice here we have a second layer of nesting so we have to do aggregation twice, first on the order level, then on resulting values. Another approach would be to use a `flatMap` to first convert initial list to list of prices, then sum it up with fold.

`reduce` is the name that is often used for another variation of this function, which can be defined with following signature:

```go
func reduce[T any](ts []T, initial T, agg func(T, T) T) T
```

As we see here, this definition of `reduce` does not allow collection and result of aggregation to be of different type, which is less powerful and more restrictive way to define this aggregation. Nevertheless it would work in simple use-case of computing total price of slice of orders, but `fold` can be used to compute much more than that, more on that in the next chapters.
