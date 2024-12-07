import gleam/dict
import gleam/io
import gleam/list
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

pub fn pt_1(parsed_input: #(GuardMap, #(Int, Int))) {
  let #(map, guard_start) = parsed_input

  map
  |> patrol_loop(guard_start)
  |> dict.to_list
  |> list.count(fn(x) {
    case x.1 {
      Pathed(_) -> True
      _ -> False
    }
  })
}

pub fn pt_2(parsed_input: #(GuardMap, #(Int, Int))) {
  let #(map, guard_start) = parsed_input

  map
  |> patrol_loop(guard_start)
  |> dict.filter(fn(pos, x) {
    {
      x == Pathed(Up)
      || x == Pathed(Left)
      || x == Pathed(Right)
      || x == Pathed(Down)
    }
    && pos != guard_start
  })
  |> dict.keys
  |> list.fold(0, fn(accum, place) {
    case patrol_loop_obstacles(dict.insert(map, place, Obstacle), guard_start) {
      True -> accum + 1
      False -> accum
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

fn patrol_loop_obstacles(map: GuardMap, guard_location: #(Int, Int)) -> Bool {
  let guard_tile = dict.get(map, guard_location) |> result.unwrap(Guard(Up))

  let direction = case guard_tile {
    Guard(dir) -> dir
    _ -> Up
  }

  let next_location_tile = next_coords(guard_location, direction)

  let map =
    map
    |> dict.insert(guard_location, Pathed(direction))

  case dict.get(map, next_location_tile) {
    Ok(next_object) ->
      case next_object {
        Pathed(dir) ->
          case dir == direction {
            False ->
              patrol_loop_obstacles(
                map
                  |> dict.insert(next_location_tile, Guard(direction)),
                next_location_tile,
              )
            True -> True
          }

        Clear ->
          patrol_loop_obstacles(
            map
              |> dict.insert(next_location_tile, Guard(direction)),
            next_location_tile,
          )

        Obstacle -> {
          let new_direction = redirect_guard(direction)
          let next_location = next_coords(guard_location, new_direction)

          case dict.get(map, next_location) {
            Ok(Obstacle) -> True
            Ok(_) | _ ->
              patrol_loop_obstacles(
                map
                  |> dict.insert(next_location, Guard(new_direction)),
                next_location,
              )
          }
        }
        _ -> False
      }
    _ -> False
  }
}

fn patrol_loop(map: GuardMap, guard_location: #(Int, Int)) -> GuardMap {
  let guard_tile = dict.get(map, guard_location) |> result.unwrap(Guard(Up))

  let direction = case guard_tile {
    Guard(dir) -> dir
    _ -> Up
  }

  let next_location_tile = next_coords(guard_location, direction)

  let map =
    map
    |> dict.insert(guard_location, Pathed(direction))

  case dict.get(map, next_location_tile) {
    Ok(next_object) ->
      case next_object {
        Clear | Pathed(_) ->
          patrol_loop(
            map
              |> dict.insert(next_location_tile, Guard(direction)),
            next_location_tile,
          )

        Obstacle -> {
          let new_direction = redirect_guard(direction)
          let next_location = next_coords(guard_location, new_direction)

          patrol_loop(
            map
              |> dict.insert(next_location, Guard(new_direction)),
            next_location,
          )
        }
        _ -> map
      }
    _ -> map
  }
}

pub fn parse(input: String) -> #(GuardMap, #(Int, Int)) {
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

  let starting_pos =
    positions
    |> dict.filter(fn(_, sort) {
      sort == Guard(Up)
      || sort == Guard(Down)
      || sort == Guard(Left)
      || sort == Guard(Right)
    })
    |> dict.keys
    |> list.first
    |> result.unwrap(#(0, 0))

  #(positions, starting_pos)
}
