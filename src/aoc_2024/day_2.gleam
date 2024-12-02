import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils

fn is_safe(numbers: List(Int)) -> Bool {
  let differences =
    numbers
    |> list.window_by_2
    |> list.map(fn(window) { window.0 - window.1 })

  list.all(differences, fn(num) { num <= 3 && num >= 1 })
  || list.all(differences, fn(num) { num <= -1 && num >= -3 })
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.filter_map(fn(report) {
    let numbers =
      report
      |> string.split(" ")
      |> list.map(fn(str) { int.parse(str) |> result.unwrap(0) })

    case is_safe(numbers) {
      True -> Ok(Nil)
      False -> Error(Nil)
    }
  })
  |> list.length
}

pub fn is_safe_dampened(report: List(Int)) {
  use <- bool.guard(is_safe(report), return: True)
  use index <- list.any(list.range(0, list.length(report) - 1))
  let #(_, remaining) =
    report
    |> list.index_map(fn(score, index) { #(index, score) })
    |> list.key_pop(index)
    |> result.unwrap(#(0, []))

  remaining
  |> list.map(fn(pair) { pair.1 })
  |> is_safe
}

pub fn pt_2(input: String) {
  input
  |> utils.lines
  |> list.map(fn(report) {
    report
    |> string.split(" ")
    |> list.map(utils.parse_int)
  })
  |> list.count(is_safe_dampened)
}
