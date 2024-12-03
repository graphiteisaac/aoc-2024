import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result
import gleam/string
import utils

pub fn pt_1(input: String) {
  let assert Ok(re) =
    regexp.compile(
      "mul\\((\\d{1,3}),(\\d{1,3})\\)",
      regexp.Options(case_insensitive: True, multi_line: True),
    )

  input
  |> regexp.scan(re, _)
  |> list.map(fn(match) {
    let values =
      match.submatches
      |> list.map(fn(x) { x |> option.unwrap("0") |> utils.parse_int })

    #(
      values |> list.first |> result.unwrap(0),
      values |> list.last |> result.unwrap(0),
    )
  })
  |> list.fold(0, fn(accum, mul) { accum + { mul.0 * mul.1 } })
}

pub type ComputerState {
  Do
  Dont
}

pub fn try_parse_mul(expr: String) -> Result(#(Int, Int), Nil) {
  let parsed =
    expr
    |> string.split(",")

  use <- bool.guard(list.length(parsed) != 2, return: Error(Nil))
  use left <- result.try(int.parse(list.first(parsed) |> result.unwrap("0")))
  use right <- result.try(int.parse(list.last(parsed) |> result.unwrap("0")))

  Ok(#(left, right))
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

pub fn pt_2(input: String) {
  input
  |> parse_part_two([], Do)
  |> list.fold(0, fn(accum, mul) { accum + { mul.0 * mul.1 } })
}
