defmodule Day14.Nanofactory do
  @doc """
      iex> Day14.Nanofactory.part1("day14-sample0.txt")
      31
      iex> Day14.Nanofactory.part1("day14-sample1.txt")
      165
      iex> Day14.Nanofactory.part1("day14-sample2.txt")
      13312
      iex> Day14.Nanofactory.part1("day14-sample3.txt")
      180697
      iex> Day14.Nanofactory.part1("day14-sample4.txt")
      2210736
      iex> Day14.Nanofactory.part1("day14.txt")
      504284
  """
  def part1(filename) do
    for _i <- 1..100 do
      parse_input_into_recipe_tree(filename)
      |> find_lowest_cost
    end
    |> Enum.sort()
    |> List.first()
  end

  @doc """
      iex> Day14.Nanofactory.parse_input_into_recipe_tree("day14-sample1.txt")
      %{"A" => [{2, [{"ORE", 9}]}], "AB" => [{1, [{"A", 3}, {"B", 4}]}], "B" => [{3, [{"ORE", 8}]}],
        "BC" => [{1, [{"B", 5}, {"C", 7}]}], "C" => [{5, [{"ORE", 7}]}], "CA" => [{1, [{"C", 4}, {"A", 1}]}],
        "FUEL" => [{1, [{"AB", 2}, {"BC", 3}, {"CA", 4}]}]}
  """
  def parse_input_into_recipe_tree(filename) do
    "inputs/#{filename}"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(" => ")
    end)
    |> Enum.map(&reaction_to_recipe/1)
    |> master_recipe_tree
  end

  def reaction_to_recipe([input_str, output_str]) do
    {output, qty} = parse_recipe_output(output_str)
    {output, {qty, parse_recipe_inputs(input_str)}}
  end

  @doc """
      iex> Day14.Nanofactory.parse_recipe_output("2 A")
      {"A", 2}
  """
  def parse_recipe_output(output_str) do
    [qty_str, output] = String.split(output_str, " ")
    {output, String.to_integer(qty_str)}
  end

  @doc """
      iex> Day14.Nanofactory.parse_recipe_inputs("3 A, 4 B")
      [{"A", 3}, {"B", 4}]
  """
  def parse_recipe_inputs(input_str) do
    input_str
    |> String.split(", ")
    |> Enum.map(fn str ->
      [qty, chemical] = String.split(str, " ")
      {chemical, String.to_integer(qty)}
    end)
  end

  def master_recipe_tree(recipes, master_list \\ %{})
  def master_recipe_tree([], master_list), do: master_list

  def master_recipe_tree([{output, recipe} | recipes], master_list) do
    recipes_for_output = [recipe | Map.get(master_list, output, [])]
    master_recipe_tree(recipes, Map.put(master_list, output, recipes_for_output))
  end

  @doc """
      iex> Day14.Nanofactory.find_lowest_cost(%{"FUEL" => [{1, [{"ORE", 123}]}]})
      123
      iex> Day14.Nanofactory.find_lowest_cost(%{"FUEL" => [{1, [{"ORE", 123}]}, {1, [{"ORE", 234}]}]})
      123
      iex> Day14.Nanofactory.find_lowest_cost(%{"FUEL" => [{1, [{"A", 2}]}], "A" => [{1, [{"ORE", 2}]}]})
      4
      iex> Day14.Nanofactory.find_lowest_cost(%{"FUEL" => [{1, [{"A", 2}, {"B", 1}]}], "A" => [{1, [{"ORE", 2}]}], "B" => [{1, [{"ORE", 3}]}]})
      7
      iex> Day14.Nanofactory.find_lowest_cost(%{"FUEL" => [{1, [{"A", 7}, {"C", 1}]}], "A" => [{10, [{"ORE", 10}]}], "B" => [{1, [{"ORE", 1}]}], "C" => [{1, [{"A", 7}, {"B", 1}]}]})
      21
  """
  def find_lowest_cost(master_recipe_tree, requirements \\ [{"FUEL", 1}], stock \\ %{})
  def find_lowest_cost(_master_recipe_tree, [], _stock), do: 0

  def find_lowest_cost(master_recipe_tree, [requirement | requirements], stock) do
    {required_chemical, required_qty} = requirement
    # IO.inspect([requirement | requirements], label: "WANT")
    # IO.inspect(stock, label: "HAVE")

    # if multiple options, pursue each in parallel
    master_recipe_tree[required_chemical]
    |> Enum.map(fn recipe -> recipe_with_multiplier(recipe, required_qty) end)
    |> Enum.map(fn {multiplier, {produced_qty, inputs}} ->
      # from this point, it's considered that we ran the reaction with the multiplier
      stock_of_required_chemical = Map.get(stock, required_chemical, 0)

      stock =
        Map.put(stock, required_chemical, stock_of_required_chemical + produced_qty * multiplier)

      # IO.inspect(stock, label: "HAVE (following reaction)")
      # IO.inspect({required_chemical, required_qty}, label: "Using")

      stock =
        Map.put(
          stock,
          required_chemical,
          stock_of_required_chemical + produced_qty * multiplier - required_qty
        )

      # IO.inspect(stock, label: "HAVE (after using what we need)")

      case inputs do
        # if we are down to only ore, then can start evaluating
        [{"ORE", ore_qty}] ->
          # IO.puts(
          #   "=== #{ore_qty * multiplier} ORE USED to produce #{produced_qty * multiplier} #{
          #     required_chemical
          #   } ==="
          # )

          ore_qty * multiplier + find_lowest_cost(master_recipe_tree, requirements, stock)

        # otherwise, proceed down the rabbit hole
        [{chemical, qty} | inputs] ->
          qty_needed = qty * multiplier
          stock_of_chemical = Map.get(stock, chemical, 0)

          cond do
            # if we have enough in stock, use that
            qty_needed < stock_of_chemical ->
              stock = Map.put(stock, chemical, stock_of_chemical - qty_needed)

              find_lowest_cost(
                master_recipe_tree,
                combine_requirements(requirements, multiply_inputs(inputs, multiplier)),
                stock
              )

            true ->
              # use what we have (if any) and make the rest
              qty_needed = qty_needed - stock_of_chemical
              stock = Map.put(stock, chemical, 0)

              find_lowest_cost(
                master_recipe_tree,
                combine_requirements(
                  requirements,
                  [{chemical, qty_needed} | multiply_inputs(inputs, multiplier)]
                ),
                stock
              )
          end
      end
    end)
    |> List.flatten()
    |> Enum.sort()
    # |> IO.inspect(charlists: false)
    |> List.first()
  end

  @doc """
      iex> Day14.Nanofactory.recipe_with_multiplier({2, [{"ORE", 9}]}, 4)
      {2, {2, [{"ORE", 9}]}}
      iex> Day14.Nanofactory.recipe_with_multiplier({10, [{"ORE", 10}]}, 14)
      {2, {10, [{"ORE", 10}]}}
  """
  def recipe_with_multiplier({produced_qty, _} = recipe, desired_qty),
    do: {ceil(desired_qty / produced_qty), recipe}

  def multiply_inputs([], _multiplier), do: []

  def multiply_inputs([{chemical, qty} | inputs], multiplier) do
    [{chemical, qty * multiplier} | multiply_inputs(inputs, multiplier)]
  end

  @doc """
      iex> Day14.Nanofactory.combine_requirements([{"A", 2}], [{"A", 3}])
      [{"A", 5}]
  """
  def combine_requirements(reqs1, reqs2) do
    keys =
      (reqs1 ++ reqs2)
      |> Enum.map(fn {key, _} -> key end)
      |> Enum.uniq()

    for key <- keys do
      combined_qty =
        (reqs1 ++ reqs2)
        |> Enum.reduce(0, fn {k, qty}, acc -> if k == key, do: acc + qty, else: acc end)

      {key, combined_qty}
    end
    |> Enum.shuffle()
  end
end
