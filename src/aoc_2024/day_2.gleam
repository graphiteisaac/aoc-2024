import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.filter(fn(report) {
    let numbers =
      report
      |> string.split(" ")
      |> list.map(fn(str) { int.parse(str) |> result.unwrap(0) })

    let increments = list.zip(numbers, list.drop(numbers, 1))
    let differences = list.map(increments, fn(inc) { inc.0 - inc.1 })

    list.all(differences, fn(difference) { difference <= 3 && difference >= 1 })
    || list.all(differences, fn(difference) {
      difference <= -1 && difference >= -3
    })
  })
  |> list.length
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.filter_map(fn(report) {
    let numbers =
      report
      |> string.split(" ")
      |> list.map(fn(str) { int.parse(str) |> result.unwrap(0) })

    let increments = list.zip(numbers, list.drop(numbers, 1))
    let differences = list.map(increments, fn(inc) { inc.0 - inc.1 })

    case
      differences
      |> list.filter_map(fn(difference) {
        use <- bool.guard(
          { difference <= 3 && difference >= 1 }
            || { difference <= -1 && difference >= -3 },
          return: Ok(True),
        )

        Error(Nil)
      })
      |> list.length
    {
      0 | 1 -> Ok(True)
      _ -> Error(Nil)
    }
  })
  |> list.length
}
