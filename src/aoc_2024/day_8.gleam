import gleam/bool
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub fn pt_1(input: Input) {
  find_antinode_loop(input.map, #(input.height, input.width), set.new())
  |> set.size
}

pub fn pt_2(input: Input) {
  find_resonant_antinode_loop(
    input.map,
    #(input.height, input.width),
    set.new(),
  )
  |> set.size
}

fn find_resonant_antinode_loop(
  map: Map,
  size: #(Int, Int),
  antinodes: Antinodes,
) -> Antinodes {
  case map {
    [first, ..rest] -> {
      find_resonant_antinode_loop(
        rest,
        size,
        add_resonant_antinodes(rest, size, antinodes, first),
      )
    }
    [] -> antinodes
  }
}

fn create_all_resonant_antinodes(
  antinodes: Antinodes,
  size: #(Int, Int),
  root: #(Int, Int),
  distance: #(Int, Int),
  iteration: Int,
) -> Antinodes {
  let new_distance = #(iteration * distance.0, iteration * distance.1)

  use <- bool.guard(
    { root.0 + new_distance.0 > size.0 || root.1 + new_distance.1 > size.1 }
    && { root.0 - new_distance.0 < 0 || root.1 - new_distance.1 < 0 },
    return: antinodes,
  )

  create_all_resonant_antinodes(
    set.new()
      |> set.insert(#(root.0 - new_distance.0, root.1 - new_distance.1))
      |> set.insert(#(root.0 + new_distance.0, root.1 + new_distance.1))
      |> set.filter(fn(coord) {
        coord.0 >= 0 && coord.0 <= size.0 && coord.1 >= 0 && coord.1 <= size.1
      })
      |> set.union(antinodes),
    size,
    root,
    distance,
    iteration + 1,
  )
}

fn add_resonant_antinodes(
  map: Map,
  size: #(Int, Int),
  antinodes: Antinodes,
  root: #(#(Int, Int), String),
) -> Antinodes {
  let #(#(root_y, root_x), root_frequency) = root

  use antinode_set, antenna <- list.fold(map, antinodes)

  let #(#(pos_y, pos_x), frequency) = antenna
  let #(distance_y, distance_x) = #(pos_y - root_y, pos_x - root_x)

  use <- bool.guard(frequency != root_frequency, return: antinode_set)
  use <- bool.guard(distance_x == 0 && distance_y == 0, return: antinode_set)

  create_all_resonant_antinodes(
    antinode_set,
    size,
    root.0,
    #(distance_y, distance_x),
    1,
  )
  |> set.insert(#(root_y, root_x))
  |> set.union(antinode_set)
}

fn find_antinode_loop(
  map: Map,
  size: #(Int, Int),
  antinodes: Antinodes,
) -> Antinodes {
  case map {
    [first, ..rest] ->
      find_antinode_loop(
        rest,
        size,
        add_antinodes(rest, size, antinodes, first),
      )
    [] -> antinodes
  }
}

fn add_antinodes(
  map: Map,
  size: #(Int, Int),
  antinodes: Antinodes,
  root: #(#(Int, Int), String),
) -> Antinodes {
  let #(#(root_y, root_x), root_frequency) = root

  use antinode_set, antenna <- list.fold(map, antinodes)

  let #(#(pos_y, pos_x), frequency) = antenna
  let #(distance_x, distance_y) = #(pos_x - root_x, pos_y - root_y)

  use <- bool.guard(frequency != root_frequency, return: antinode_set)
  use <- bool.guard(distance_x == 0 && distance_y == 0, return: antinode_set)

  set.new()
  |> set.insert(#(root_y - distance_y, root_x - distance_x))
  |> set.insert(#(pos_y + distance_y, pos_x + distance_x))
  |> set.filter(fn(coord) {
    coord.0 >= 0 && coord.0 <= size.0 && coord.1 >= 0 && coord.1 <= size.1
  })
  |> set.union(antinode_set)
}

pub type Map =
  List(#(#(Int, Int), String))

pub type Antinodes =
  set.Set(#(Int, Int))

pub type Input {
  Input(width: Int, height: Int, map: Map)
}

pub fn parse(input: String) -> Input {
  let rows = string.split(input, "\n")
  let height = list.length(rows) - 1
  let width = string.length(list.first(rows) |> result.unwrap("")) - 1

  let map =
    {
      use line, row <- list.index_map(rows)
      use char, col <- list.index_map(string.split(line, ""))

      case char {
        "." -> Error(Nil)
        a -> Ok(#(#(row, col), a))
      }
    }
    |> list.flatten
    |> result.values
  Input(width:, height:, map:)
}
