import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub type Direction {
  Up
  Left
  Right
  Down
}

pub type Waypoint {
  Guard
  Obstacle
  Clear
}

pub type Position =
  #(Int, Int)

pub type Map =
  dict.Dict(#(Int, Int), Waypoint)

pub fn pt_1(parsed_input: #(Map, Position)) {
  let #(map, guard_start) = parsed_input

  find_visited(map, set.new(), guard_start, Up)
  |> set.size
}

pub fn pt_2(parsed_input: #(Map, Position)) {
  let #(map, guard_start) = parsed_input
  let visited = find_visited(map, set.new(), guard_start, Up)

  use accum, position <- set.fold(visited, 0)
  let new_map = dict.insert(map, position, Obstacle)

  case patrol(new_map, set.new(), guard_start, Up) {
    False -> accum
    True -> accum + 1
  }
}

fn get_rotated_idiot(dir: Direction) -> Direction {
  case dir {
    Down -> Left
    Left -> Up
    Up -> Right
    Right -> Down
  }
}

pub fn move(position: Position, direction: Direction) -> Position {
  case direction {
    Up -> #(position.0 - 1, position.1)
    Left -> #(position.0, position.1 - 1)
    Right -> #(position.0, position.1 + 1)
    Down -> #(position.0 + 1, position.1)
  }
}

fn find_visited(
  map: Map,
  visited: set.Set(Position),
  position: Position,
  direction: Direction,
) -> set.Set(Position) {
  let next_position = move(position, direction)

  case dict.get(map, next_position) {
    Ok(Obstacle) ->
      find_visited(map, visited, position, get_rotated_idiot(direction))
    Ok(Clear) | Ok(Guard) ->
      find_visited(
        map,
        set.insert(visited, next_position),
        next_position,
        direction,
      )
    _ -> visited
  }
}

fn patrol(
  map: Map,
  visited: set.Set(#(Position, Direction)),
  position: Position,
  direction: Direction,
) -> Bool {
  let next_position = move(position, direction)

  case
    dict.get(map, next_position),
    set.contains(visited, #(next_position, direction))
  {
    Error(_), _ -> False
    _, True -> True
    Ok(Obstacle), _ -> {
      let new_direction = get_rotated_idiot(direction)
      patrol(map, visited, position, new_direction)
    }
    Ok(Clear), _ | Ok(Guard), _ ->
      patrol(
        map,
        set.insert(visited, #(next_position, direction)),
        next_position,
        direction,
      )
  }
}

pub fn parse(input: String) -> #(Map, Position) {
  let positions =
    {
      use line, row <- list.index_map(string.split(input, "\n"))
      use char, col <- list.index_map(string.split(line, ""))

      let map_object = case char {
        "^" -> Guard
        "#" -> Obstacle
        _ -> Clear
      }

      #(row, col, map_object)
    }
    |> list.flatten
    |> list.fold(dict.new(), fn(accum, item) {
      let #(row, col, char) = item
      dict.insert(accum, #(row, col), char)
    })

  let starting_pos =
    positions
    |> dict.filter(fn(_, sort) { sort == Guard })
    |> dict.keys
    |> list.first
    |> result.unwrap(#(0, 0))

  #(positions, starting_pos)
}
