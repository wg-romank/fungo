# Revisiting filter and flatMap

This chapter does not have a lot of information that can be immediately applied in practice like few previous ones. Its purpose is to have another look at the operations we have defined and implemented so far and try to draw relationships between them, hopefully building up some intuition of how to use them or not to use them.

Before it starts to sound too abstract let's first have a look at `flatMap` and `filter`. They clearly serve different purpose, we've been using `flatMap` to get rid of extra nesting layers and `filter` to sieve collection so we only get elements matching some predefined condition. However if we look at their properties we should be able to see some similarity. `flatMap` expands each element of initial collection into many (recalling order / item example, todo: check), there could be a case where order is empty thus having 0 items attached to it. Such order looks like erroneous but it still can exist along paths of execution of our service. So this 'one' to 'many' mapping could include 0 on the right side. Now let's look at `filter`, given initial collection we want to get only elements that are only satisfying some criteria, in other terms we could say that any item that is not satisfying desired condition is mapped to nothing, but this is very similar to our empty order case for `flatMap`. So it looks like we can imitate behavior of `filter` with `flatMap`, our mapping function just needs to output empty slice in case where condition is not satisfied.

Let's have a look at previous example for `filter` and implement it in terms of `flatMap`. We previously used `filter` to get a subset of orders which have been shipped.

```go
shippedOrders := filter(orders, func(o Order) bool { return o.shipped })
// this can be rephrased as a call to flatMap 
shippedOrders = flatMap(orders, func(o Order) []Order {
  if o.shipped {
    return []{o};
  } else {
    return []{};
})
```

Here we do the same check on `o.shipped` and we either return an empty slice that gets ignored in final result after flattening or we return a slice containing the order in case condition is satisfied. As you can see it is quite mouthful compared to a single `filter` call and we have to create a bunch of temporary objects that get discarded immediately, but the fact that we can substitute one primitive for another to get the same behavior is a hint that we are onto something with how those operations are defined.

Armed with this knowledge we can rewrite original `filter` primitive in terms of calling `flatMap`.

```go
func filter[T any](ts []T, condition func(T) bool) []T {
  return flatMap(ts, func(t T) []T {
    if condition(t) {
      return []T{t};
    else {
      return []{};
    }
  })
```

Notice, here we do not have to manually go over input slice `ts`, we simply provided a function for `flatMap` to execute and it will cover all the cases for `filter`. We call this implementation 'compositional' since it reuses primitives we have defined previously and while it has other flaws, like allocating temporary objects it clearly has some benefits too.
