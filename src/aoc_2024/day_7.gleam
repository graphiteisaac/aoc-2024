import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: List(#(Int, List(Int)))) {
  use sum, #(desired, inputs) <- list.fold(input, 0)
  let assert [first, ..numbers] = inputs

  case solve(desired, first, numbers, [Add, Mul]) {
    True -> sum + desired
    False -> sum
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  use sum, #(desired, inputs) <- list.fold(input, 0)
  let assert [first, ..numbers] = inputs

  case solve(desired, first, numbers, [Add, Mul, Concat]) {
    True -> sum + desired
    False -> sum
  }
}

fn apply_operator(op, accum, x) {
  case op {
    Add -> accum + x
    Mul -> accum * x
    Concat -> concat(accum, x)
  }
}

fn solve(desired, accum, rest, ops) {
  case rest {
    [] -> accum == desired
    [x, ..remaining] ->
      list.any(ops, fn(op) {
        solve(desired, apply_operator(op, accum, x), remaining, ops)
      })
  }
}

fn concat(left: Int, right: Int) -> Int {
  int.undigits(
    list.append(
      int.digits(left, 10) |> result.unwrap([]),
      int.digits(right, 10) |> result.unwrap([]),
    ),
    10,
  )
  |> result.unwrap(0)
}

type Op {
  Add
  Mul
  Concat
}

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  use line <- list.map(
    input
    |> string.split("\n"),
  )

  let assert Ok(#(desired, inputs)) = line |> string.split_once(": ")

  #(
    desired |> int.parse |> result.unwrap(0),
    inputs |> string.split(" ") |> list.filter_map(int.parse),
  )
}
