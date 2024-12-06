import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

type Board =
  Dict(#(Int, Int), String)

fn parse_board(input: String) -> Board {
  let lines =
    input
    |> string.split("\n")

  use board, line, row <- list.index_fold(lines, dict.new())
  let line_graphemes = string.to_graphemes(line)
  use board, character, column <- list.index_fold(line_graphemes, board)

  board
  |> dict.insert(#(row, column), character)
}

fn solve_part_one(board: Board) -> Int {
  use count, #(row, col), _char <- dict.fold(board, 0)

  {
    [
      // ˃
      [#(row, col), #(row, col + 1), #(row, col + 2), #(row, col + 3)],
      // ˃˅
      [
        #(row, col),
        #(row + 1, col + 1),
        #(row + 2, col + 2),
        #(row + 3, col + 3),
      ],
      // ˅
      [#(row, col), #(row + 1, col), #(row + 2, col), #(row + 3, col)],
      // ˅˂
      [
        #(row, col),
        #(row + 1, col - 1),
        #(row + 2, col - 2),
        #(row + 3, col - 3),
      ],
      // ˂
      [#(row, col), #(row, col - 1), #(row, col - 2), #(row, col - 3)],
      // ˂˄
      [
        #(row, col),
        #(row - 1, col - 1),
        #(row - 2, col - 2),
        #(row - 3, col - 3),
      ],
      // ˄
      [#(row, col), #(row - 1, col), #(row - 2, col), #(row - 3, col)],
      // ˄˃
      [
        #(row, col),
        #(row - 1, col + 1),
        #(row - 2, col + 2),
        #(row - 3, col + 3),
      ],
    ]
    |> list.fold(0, fn(count, word) {
      case find_word(board, word) {
        Ok("XMAS") -> count + 1
        _ -> count
      }
    })
  }
  + count
}

fn solve_part_two(board: Board) -> Int {
  use count, #(row, col), _char <- dict.fold(board, 0)

  // cross part |
  let cross_one = [#(row - 1, col - 1), #(row, col), #(row + 1, col + 1)]
  // cross part /
  let cross_two = [#(row - 1, col + 1), #(row, col), #(row + 1, col - 1)]

  case find_word(board, cross_one), find_word(board, cross_two) {
    Ok("MAS"), Ok("SAM")
    | Ok("SAM"), Ok("MAS")
    | Ok("SAM"), Ok("SAM")
    | Ok("MAS"), Ok("MAS")
    -> 1
    _, _ -> 0
  }
  + count
}

fn find_word(board: Board, points) {
  use str, point <- list.try_fold(points, "")
  use char <- result.try(dict.get(board, point))

  Ok(str <> char)
}

pub fn pt_1(input: String) {
  input
  |> parse_board
  |> solve_part_one
}

pub fn pt_2(input: String) {
  input
  |> parse_board
  |> solve_part_two
}
