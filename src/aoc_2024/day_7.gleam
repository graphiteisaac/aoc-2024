import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: List(Equation)) {
  list.filter_map(input, solve(_, [Add, Mul]))
  |> list.fold(0, fn(accum, exists) { accum + exists })
}

pub fn pt_2(_input: List(Equation)) {
  0
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

fn apply_operator(operator: Op, left: Int, right: Int) {
  case operator {
    Add -> left + right
    Mul -> left * right
    Concat -> concat(left, right)
  }
}

fn solve(equation: Equation, operators: List(Op)) -> Result(Int, Nil) {
  case equation {
    Equation(target, [must_be_sum]) if must_be_sum == target -> {
      io.debug(
        int.to_string(equation.desired) <> " : " <> int.to_string(target),
      )
      Ok(target)
    }
    Equation(_, [left, right, ..rest]) -> {
      use _, operator <- list.fold_until(operators, Error(Nil))
      case
        solve(
          Equation(
            ..equation,
            inputs: [apply_operator(operator, left, right), ..rest],
          ),
          operators,
        )
      {
        Ok(t) -> list.Stop(Ok(t))
        Error(_) -> list.Continue(Error(Nil))
      }
    }
    _ -> Error(Nil)
  }
}

pub type Equation {
  Equation(desired: Int, inputs: List(Int))
}

pub type Op {
  Add
  Mul
  Concat
}

pub fn parse(input: String) -> List(Equation) {
  use line <- list.map(
    input
    |> string.split("\n"),
  )

  let assert [desired, inputs] = line |> string.split(": ")

  Equation(
    desired: int.parse(desired) |> result.unwrap(0),
    inputs: list.map(inputs |> string.split(" "), fn(x) {
      int.parse(x) |> result.unwrap(0)
    }),
  )
}
