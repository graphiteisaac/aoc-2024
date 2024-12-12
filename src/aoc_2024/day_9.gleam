import gleam/deque.{type Deque}
import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

fn repeat(f: fn() -> Nil, x: Int) {
  case x {
    0 -> Nil
    _ -> {
      f()
      repeat(f, x - 1)
    }
  }
}

pub fn pt_1(input: List(Block)) {
  input
  |> deque.from_list
  |> compact_memory([])
  |> checksum(0.0, 0)
}

pub fn pt_2(input: List(Block)) {
  input
  |> list.first
}

fn compact_memory(drive: Deque(Block), accum: List(Block)) -> List(Block) {
  case accum {
    [File(..), ..] | [] ->
      case deque.pop_front(drive) {
        Ok(#(block, rest)) -> compact_memory(rest, [block, ..accum])
        _ -> list.reverse(accum)
      }
    [Free(free), ..rest] ->
      case deque.pop_back(drive) {
        Ok(#(Free(_), rest)) -> compact_memory(rest, accum)
        Ok(#(File(size:, ..) as file, remaining)) ->
          case int.compare(size, free) {
            order.Eq -> compact_memory(remaining, [file, ..rest])
            order.Gt ->
              compact_memory(
                deque.push_back(remaining, File(..file, size: size - free)),
                [File(..file, size: free), ..rest],
              )
            order.Lt ->
              compact_memory(remaining, [Free(size: free - size), file, ..rest])
          }
        _ -> list.reverse(rest)
      }
  }
}

fn checksum(blocks: List(Block), index: Float, accum: Int) -> Int {
  case blocks {
    [first, ..rest] -> {
      let size_float = int.to_float(first.size)

      let addition = case first {
        File(id:, ..) -> {
          let average_index = index +. { size_float /. 2.0 } -. 0.5
          float.round({ average_index *. int.to_float(id) } *. size_float)
        }
        _ -> 0
      }

      checksum(rest, index +. int.to_float(first.size), accum + addition)
    }
    [] -> accum
  }
}

pub type Block {
  File(size: Int, id: Int)
  Free(size: Int)
}

fn parse_loop(
  file_id: Int,
  input: List(String),
  accum: List(Block),
) -> List(Block) {
  case input {
    [file, free, ..rest] -> {
      let file_count = file |> int.parse |> result.unwrap(0)
      let free_count = free |> int.parse |> result.unwrap(0)

      parse_loop(file_id + 1, rest, [
        Free(free_count),
        File(id: file_id, size: file_count),
        ..accum
      ])
    }
    [file, ..rest] -> {
      let file_count = file |> int.parse |> result.unwrap(0)
      parse_loop(file_id + 1, rest, [
        File(id: file_id, size: file_count),
        ..accum
      ])
    }
    [] -> list.reverse(accum)
  }
}

pub fn parse(input: String) -> List(Block) {
  input
  //"12345"
  |> string.split("")
  |> parse_loop(0, _, [])
}
