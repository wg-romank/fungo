# Not that kind of map

Golang's standard library lacks common operations on collections (such as `map`, `filter`, `fold`, etc.) which might be familiar for people coming from functional programming languages. Thus, any trivial operation on collection would involve creating a temporary variable and iterating over it's members in a `for`-loop. While this way of structuring the program is common across many imperative languages and there is nothing wrong with it, for me personally, coming from Scala and Rust, it looked a bit verbose so I wanted to explore what would it take to implement those operations in a general way so one can do it once and leverage their power of expression ...

We are going to make some simplifictaions first, we would need to pick a certain collection type, this is one of limitation's of Go's typesystem. Let's work with slices (`[]`).

As for operations, let's pick `map` first. Not the `map` as lookup table / dictionary that's built in the language but an operation that given some slice of type `T`, `[]T` and a function from `T` to some `U` will output an slice of `U`s, `[]U`, mapping each element with provided function.

We can encode this in Go with its generics feature

```go
func mapArr[T any, U any](arr []T, f func(T) U) []U {
  res := make([]U, len(T))
  for idx, e := range arr {
    res[idx] = f(arr[idx])
  }
  return res
}
```

Okay, this is fairly abstract, we don't specify what those `T` and `U` are, but this is a very common operation that can be used frequently. So what can we do with it?

```go
// given slice of ints
tmp := []int{1, 2, 3}
// we can double it's values
doulbed := mapArr(tmp, func(n int) int { return 2 * n })
// or we can convert then to strings
strArr := mapArr(tmp, func(n int) int { return fmt.Sprintf("%d", n) })
```

But all this is not very interesting, let's consider a bit more 'real' case where we have bunch of some structs, e.g. orders and we want to get user ids from those orders and fetch user information given those user ids from the database.

```go

type Order struct {
  userId int32
}

var orders []Order
userIds := mapArray(orders, func(o Order) int32 { return o.userId }

// or if you've got some getter for userId lyring around already
func (o Order) GetUserId() int32 {
  return o.userId
}
// you can directly use it when calling mapArray
userIds := mapArray(orders, Order.GetUserId)
```

If you are doing some data wranlging in your service chances are `map` will come in handy. If you look over your existing codebase you will spot countless instances where you perform this operation typing those `for`-loops over and over again.
