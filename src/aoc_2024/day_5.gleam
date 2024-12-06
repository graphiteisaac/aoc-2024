import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub type ParsedInput =
  #(set.Set(#(Int, Int)), List(List(Int)))

pub fn parse(input: String) -> ParsedInput {
  let assert [rules, pages] = string.split(input, "\n\n")

  let rules =
    rules
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [left, right] =
        line
        |> string.split("|")
        |> list.map(int.parse)
        |> result.values

      #(left, right)
    })
    |> list.fold(set.new(), fn(ruleset, rule) { set.insert(ruleset, rule) })

  let pages =
    pages
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.map(int.parse)
      |> result.values
    })

  #(rules, pages)
}

pub fn pt_1(input: ParsedInput) {
  let #(rules, pages) = input

  pages
  |> list.filter_map(fn(line) {
    let y =
      line
      |> list.window_by_2
      |> list.filter_map(fn(value) {
        let rights =
          rules
          |> set.filter(fn(x) { x.0 == value.0 })
          |> set.to_list

        Ok(list.any(rights, fn(x) { x.1 == value.1 }))
      })
      |> list.all(fn(x) { x == True })

    case y {
      True -> Ok(line)
      False -> Error(Nil)
    }
  })
  |> list.fold(0, fn(fold, line) {
    fold
    + {
      line
      |> list.split(list.length(line) / 2)
      |> pair.second
      |> list.first
      |> result.unwrap(0)
    }
  })
}

fn do_sort(page: List(Int), rules: set.Set(#(Int, Int))) {
  case page {
    [only] -> [only]
    [first, ..] -> {
      let #(before, after) =
        set.filter(rules, fn(rule) {
          { rule.0 == first && list.contains(page, rule.1) }
          || { rule.1 == first && list.contains(page, rule.0) }
        })
        |> set.to_list
        |> list.partition(fn(rule) { rule.1 == first })

      let before =
        before
        |> list.map(fn(rule) { rule.0 })
      let after =
        after
        |> list.map(fn(rule) { rule.1 })

      list.flatten([do_sort(before, rules), [first], do_sort(after, rules)])
    }
    [] -> []
  }
}

pub fn pt_2(input: ParsedInput) {
  let #(rules, pages) = input

  pages
  |> list.filter_map(fn(line) {
    let y =
      line
      |> list.window_by_2
      |> list.filter_map(fn(value) {
        let rights =
          rules
          |> set.filter(fn(x) { x.0 == value.0 })
          |> set.to_list

        Ok(list.any(rights, fn(x) { x.1 == value.1 }))
      })
      |> list.all(fn(x) { x == True })
  
    case y {
      False -> Ok(do_sort(line, rules))
      True -> Error(Nil)
    }
  })
  |> list.fold(0, fn(fold, line) {
    let num =
      line
      |> list.split(list.length(line) / 2)
      |> pair.second
      |> list.first
      |> result.unwrap(0)

    fold + { num }
  })
}
