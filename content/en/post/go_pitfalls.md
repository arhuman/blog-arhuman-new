+++
title = "Golang pitfalls"
categories = ["News"]
tags = ["Golang", "Programming"]
thumbnail = "img/Go_book.jpg"
type = "post"
date = "2023-05-29"
draft = true
+++

# Passing parameters by value

You all know it: Go pass parameter by value.
But sometimes those value are not what you might expect.
Let's take slices.

# := is convenient, when used properly

```go
var client string

func init() {

    client, err := GetClientValue()
        if err != nil {
            panic(err)
        }
}

func main() {
    fmt.Printf("client = %#v\n", client)
}

```

# Using embedded structs to do inheritance


```go
type Vehicule struct {
    name string = "vehicule"
    Wheels int
}

func (v Vehicule) Move() string {
    returns "moves"
}

func (v Vehicule) Name() string {
    returns  v.name
}

type Car struct {
    name string = "car"
    Vehicule
}

func (v Car) Move() string {
    returns "drives"
}

var x Car
fmt.Println (x.Name())
```
