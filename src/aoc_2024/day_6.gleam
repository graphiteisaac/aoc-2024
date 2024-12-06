import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type GuardDirection {
  Up
  Left
  Right
  Down
}

pub type MapObject {
  Guard(dir: GuardDirection)
  Obstacle
  Pathed(dir: GuardDirection)
  Clear
}

pub type GuardMap =
  dict.Dict(#(Int, Int), MapObject)

pub fn pt_1(input: GuardMap) {
  input
  |> mark_map
  |> dict.to_list
  |> list.count(fn(x) {
    case x.1 {
      Pathed(_) -> True
      _ -> False
    }
  })
}

pub fn pt_2(input: GuardMap) {
  let lst =
    input
    |> mark_map
    |> dict.filter(fn(_, x) {
      x == Pathed(Up)
      || x == Pathed(Left)
      || x == Pathed(Right)
      || x == Pathed(Down)
    })
    |> dict.keys
    |> list.unique

//  let length = list.length(lst)
  let guard_start =
    input
    |> dict.filter(fn(_, x) {
      x == Guard(Up)
      || x == Guard(Down)
      || x == Guard(Left)
      || x == Guard(Right)
    })
    |> dict.to_list
    |> list.first
    |> result.unwrap(#(#(0, 0), Guard(Up)))
    |> pair.first

  //io.debug(guard_start)

  lst
  |> list.fold(0, fn(accum, candidate) {
    //io.debug(int.to_string(accum) <> " / " <> int.to_string(length))
    case
      mark_obstacle_map(
        input |> dict.insert(candidate, Obstacle),
        guard_start,
        Up,
      )
    {
      False -> accum
      True -> accum + 1
    }
  })
}

fn redirect_guard(dir: GuardDirection) -> GuardDirection {
  case dir {
    Down -> Left
    Left -> Up
    Up -> Right
    Right -> Down
  }
}

fn next_coords(location: #(Int, Int), direction: GuardDirection) -> #(Int, Int) {
  case direction {
    Up -> #(location.0 - 1, location.1)
    Right -> #(location.0, location.1 + 1)
    Down -> #(location.0 + 1, location.1)
    Left -> #(location.0, location.1 - 1)
  }
}

fn mark_obstacle_map(
  map: GuardMap,
  guard_location: #(Int, Int),
  direction: GuardDirection,
) -> Bool {
  let next_location_tile = next_coords(guard_location, direction)

  let map =
    map
    |> dict.insert(guard_location, Pathed(direction))

  case dict.get(map, next_location_tile) {
    Ok(next_object) ->
      case next_object {
        Pathed(dir) -> {
          use <- bool.guard(dir == direction, return: True)
          mark_obstacle_map(
            map
              |> dict.insert(next_location_tile, Guard(direction)),
            next_location_tile,
            direction,
          )
        }

        Clear ->
          mark_obstacle_map(
            map
              |> dict.insert(next_location_tile, Guard(direction)),
            next_location_tile,
            direction,
          )

        Obstacle -> {
          let new_direction = redirect_guard(direction)
          let next_location = next_coords(guard_location, new_direction)

          mark_obstacle_map(
            map
              |> dict.insert(next_location, Guard(new_direction)),
            next_location,
            new_direction,
          )
        }
        _ -> False
      }
    _ -> False
  }
}

fn mark_map(map: GuardMap) -> GuardMap {
  let guard_location =
    dict.filter(map, fn(_, x) {
      case x {
        Guard(_) -> True
        _ -> False
      }
    })
    |> dict.to_list
    |> list.first
    |> result.unwrap(#(#(0, 0), Guard(Up)))

  let direction = case guard_location.1 {
    Guard(dir) -> dir
    _ -> Up
  }

  let next_location_tile = next_coords(guard_location.0, direction)

  let map =
    map
    |> dict.insert(guard_location.0, Pathed(direction))

  case dict.get(map, next_location_tile) {
    Ok(next_object) ->
      case next_object {
        Clear | Pathed(_) ->
          mark_map(
            map
            |> dict.insert(next_location_tile, Guard(direction)),
          )

        Obstacle -> {
          let new_direction = redirect_guard(direction)
          let next_location = next_coords(guard_location.0, new_direction)

          mark_map(
            map
            |> dict.insert(next_location, Guard(new_direction)),
          )
        }
        _ -> map
      }
    _ -> map
  }
}

pub fn parse(input: String) -> GuardMap {
  let positions =
    {
      use line, row <- list.index_map(string.split(input, "\n"))
      use char, col <- list.index_map(string.split(line, ""))

      let map_object = case char {
        "^" -> Guard(Up)
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

  positions
}
