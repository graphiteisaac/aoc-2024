import gleam/int
import gleam/list
import gleam/result
import gleam/string

// Expects both lists to be sorted
fn solve_part_one(left: List(Int), right: List(Int), dist: Int) {
  case left {
    [first, ..rest] -> {
      let right_remaining = list.rest(right) |> result.unwrap([])
      solve_part_one(rest, right_remaining, {
        dist
        + {
          int.subtract(
            first,
            list.first(right)
              |> result.unwrap(0),
          )
          |> int.absolute_value
        }
      })
    }
    _ -> dist
  }
}

pub fn pt_1(input: String) {
  let #(left, right) =
    input
    |> string.split(on: "\n")
    |> list.map(fn(line) {
      let sections =
        line
        |> string.split("   ")

      let left =
        list.first(sections)
        |> result.unwrap("0")
        |> int.parse()
        |> result.unwrap(0)

      let right =
        list.last(sections)
        |> result.unwrap("0")
        |> int.parse()
        |> result.unwrap(0)

      #(left, right)
    })
    |> list.unzip

  let left = list.sort(left, by: int.compare)
  let right = list.sort(right, by: int.compare)

  solve_part_one(left, right, 0)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
