import gleam/int
import gleam/result
import gleam/string

pub fn lines(input: String) -> List(String) {
  string.split(input, "\n")
}

pub fn parse_int(str: String) -> Int {
  int.parse(str) |> result.unwrap(0)
}
