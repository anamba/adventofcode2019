defmodule Day3.IntersectionFinder do
  @directions %{"R" => :right, "L" => :left, "U" => :up, "D" => :down}

  def run do
    "inputs/day3.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> parse_move_list() |> move_list_to_point_list
    end)
    |> find_intersections
    |> distance_to_closest_intersection
  end

  @doc """
      iex> Day3.IntersectionFinder.parse_move_list("R75,D30")
      [{:right, 75}, {:down, 30}]
  """
  def parse_move_list(moves_str) do
    moves_str
    |> String.split(",")
    |> Enum.map(fn move_str ->
      parts = String.split_at(move_str, 1) |> Tuple.to_list()
      {@directions[Enum.at(parts, 0)], String.to_integer(Enum.at(parts, 1))}
    end)
  end

  @doc """
      iex> Day3.IntersectionFinder.move_list_to_point_list([{:right, 2}, {:down, 3}])
      [{1,0}, {2,0}, {2,-1}, {2,-2}, {2,-3}]
  """
  def move_list_to_point_list(moves, start \\ {0, 0}, points \\ [])

  def move_list_to_point_list([], _start, points) do
    points
  end

  def move_list_to_point_list([move | moves], start, points) do
    new_points = move_to_point_list(move, start)
    move_list_to_point_list(moves, Enum.at(new_points, -1), points ++ new_points)
  end

  @doc """
      iex> Day3.IntersectionFinder.move_to_point_list({:right, 2}, {0, 0})
      [{1,0}, {2,0}]
      iex> Day3.IntersectionFinder.move_to_point_list({:down, 3}, {2, 0})
      [{2,-1}, {2,-2}, {2,-3}]
  """
  def move_to_point_list({direction, distance}, {x, y}) do
    case direction do
      :right -> for newx <- (x + 1)..(x + distance), do: {newx, y}
      :left -> for newx <- (x - 1)..(x - distance), do: {newx, y}
      :up -> for newy <- (y + 1)..(y + distance), do: {x, newy}
      :down -> for newy <- (y - 1)..(y - distance), do: {x, newy}
    end
  end

  @doc """
      iex> Day3.IntersectionFinder.find_intersections([[{1,0}, {2,0}, {2,-1}, {2,-2}], [{0,1}, {1,1}, {2,1}, {2,0}]])
      [{2,0}]
  """
  def find_intersections([points1, points2]) do
    points1 -- points1 -- points2
  end

  @doc """
      iex> Day3.IntersectionFinder.distance_to_closest_intersection([{2,0}, {4,5}])
      2
  """
  def distance_to_closest_intersection(intersections) do
    intersections
    |> Enum.reduce(:math.pow(2, 30), fn point, min_dist ->
      dist = manhattan_distance({0, 0}, point)
      Enum.min([dist, min_dist])
    end)
  end

  @doc """
      iex> Day3.IntersectionFinder.manhattan_distance({0,0}, {3,3})
      6
      iex> Day3.IntersectionFinder.manhattan_distance({-2,5}, {3,-5})
      15
  """
  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end
