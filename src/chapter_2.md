# Filter and flat map

Okay we discovered this useful operation that handles cases of 1-to-1 mapping. In our previous examples all orders had `userId` thus we could map it 1-to-1. Naturally not all use-cases are handled neatly by map. Extending our previous example of working with orders let's extend data definition a bit.

```go
type Item struct { }

type Order struct {
  userId int32
  shipped bool
  goods []Item
}
```

Here we defined a few new fields, `shipped` is a boolean flag that marks order shipping status, and `goods` is another slice of items included in order. We omit `Item` fields definition since they do not matter much for now.

Now let's say we want to get a slice of shipped orders, we can do so with another generic operation commonly referred to as `filter`. This function would transform our initial slice of `T`s `[]T` to another slice of `T`s `[]T` given a predicate (condition) that is another function from `T` to `bool`.

In order to answer our question of shipped orders we could use `filter` as follows

```go
shippedOrders := filter(orders, func(o Order) bool { return o.shipped })
// again if we have a getter for shipping status already
func (o Order) isShipped() bool { return o.shipped }
// we can simply substitute it in filter function invocation
shippedOrders := filter(orders, Order.isShipped)
```

Filter implementation is also quite simple, we just need to create a new slice that would include only items satisfying the condition of the predicate function supplied, here's one implementation using `append`.

```go
func filter[T any](ts []T, condition func(T) bool) []T {
  var res []T
  for _, t := range ts {
    if condition(t) {
      res = append(res, t)
    }
  }
  return res
}
```

Another use-case we could cover is getting the slice of items of orders. Since each order is including a slice of items we need to somehow flatten this structure into a single slice. `flatMap` comes to the rescue, this operation is somewhat similar to `map`, but works with 1-to-many relationships, which is the case we have with orders and items.

`flatMap` again can be defined generically, it takes a slice of `T`s `[]T` and a function from `T` to slice of `U`s `[]U` and produces a slice of `U`s `[]U`.

How can we get a slice of items from bunch of orders using `flatMap`? Here's an example of calling it

```go
items := flatMap(orders, func(o Order) []Item { return o.goods })
```

And the implementation of `flatMap` itself

```go

func flatMap[T any](ts []T, project func(T) []U) []U {
  var res []U
  for _, t := range ts {
    res = append(res, project(t)...)
  }
  return res
}
```

Here we use Go's builtin unpack operator `...` before passing result to `append` since each call of `project` produces multiple values of type `U`. In our order-goods example `U` would be `Item`.
