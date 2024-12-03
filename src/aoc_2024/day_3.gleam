import gleam/bool
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn try_parse_mul(expr: String) -> Result(#(Int, Int), Nil) {
  let parsed =
    expr
    |> string.split(",")

  use <- bool.guard(list.length(parsed) != 2, return: Error(Nil))
  use left <- result.try(int.parse(list.first(parsed) |> result.unwrap("0")))
  use right <- result.try(int.parse(list.last(parsed) |> result.unwrap("0")))

  Ok(#(left, right))
}

pub fn parse_part_one(
  input: String,
  accum: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case input {
    "" -> accum
    "mul(" <> rest -> {
      let #(muls, after) =
        rest |> string.split_once(")") |> result.unwrap(#("", ""))

      case try_parse_mul(muls) {
        Error(_) -> parse_part_one(rest, accum)
        Ok(t) -> parse_part_one(after, list.append(accum, [t]))
      }
    }
    _ ->
      input
      |> string.pop_grapheme
      |> result.map(pair.second)
      |> result.unwrap("")
      |> parse_part_one(accum)
  }
}

pub fn parse_part_two(
  input: String,
  accum: List(#(Int, Int)),
  state: ComputerState,
) -> List(#(Int, Int)) {
  case input {
    "" -> accum
    "mul(" <> rest ->
      case state {
        Do -> {
          let #(muls, after) =
            rest |> string.split_once(")") |> result.unwrap(#("", ""))

          case try_parse_mul(muls) {
            Error(_) -> parse_part_two(rest, accum, state)
            Ok(t) -> parse_part_two(after, list.append(accum, [t]), state)
          }
        }
        _ -> parse_part_two(rest, accum, state)
      }
    "don't()" <> rest -> parse_part_two(rest, accum, Dont)
    "do()" <> rest -> parse_part_two(rest, accum, Do)
    _ ->
      input
      |> string.pop_grapheme
      |> result.map(pair.second)
      |> result.unwrap("")
      |> parse_part_two(accum, state)
  }
}

pub type ComputerState {
  Do
  Dont
}

pub fn pt_1(input: String) {
  input
  |> parse_part_one([])
  |> list.fold(0, fn(accum, mul) { accum + { mul.0 * mul.1 } })
}

pub fn pt_2(input: String) {
  input
  |> parse_part_two([], Do)
  |> list.fold(0, fn(accum, mul) { accum + { mul.0 * mul.1 } })
}
