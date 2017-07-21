defmodule EctoSchemaless do
  @moduledoc """
  Documentation for EctoSchemaless.

  This library makes working without schemas possible while still using your
  Ecto.Repo implementation. It is designed to work alongside Ecto in scenarios
  where the schema is not flexible enough.

  At the moment, it only supports direct SQL, so be careful and stuff...
  """

  @type attribute_set :: Map.t
  @type id :: Integer.t
  @type response :: [map] | []
  @type sql :: String.t
  @type table_name :: String.t

  @doc """
  ```elixir
  EctoSchemaless.delete!(MyRepo, "DELETE FROM my_table WHERE id = 1")
  %Postgrex.Result{columns: nil, command: :delete, connection_id: 57048,
   num_rows: 1, rows: nil}
  ```
  """
  @spec delete!(Exto.Repo.t, sql) :: response
  def delete!(repo, sql), do: Ecto.Adapters.SQL.query!(repo, sql)

  @doc """
  ```elixir
  EctoSchemaless.insert!(MyRepo, "my_table", %{name: "Demo"})
  [%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}}, name: "Demo",
     updated_at: {{2017, 7, 21}, {14, 49, 34, 124176}}}]
  ```
  """
  @spec insert!(Ecto.Repo.t, table_name, attribute_set) :: response
  def insert!(repo, table_name, attributes) do
    now = DateTime.utc_now()
    attributes = Map.merge(attributes, %{inserted_at: now, updated_at: now})

    returning = [:id] ++ Map.keys(attributes)

    table_name
    |> repo.insert_all([attributes], returning: returning)
    |> elem(1)
  end

  @doc """
  ```elixir
  EctoSchemaless.select!(MyRepo, "SELECT * FROM my_table WHERE id = 1")
  [%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}}, name: "Demo",
     updated_at: {{2017, 7, 21}, {14, 49, 34, 124176}}}]
  ```
  """
  @spec select!(Ecto.Repo.t, sql) :: response
  def select!(repo, sql) do
    result = Ecto.Adapters.SQL.query!(repo, sql)
    columns = Enum.map(result.columns, &String.to_atom/1)
    Enum.map(result.rows, &row_to_map(columns, &1))
  end

  @doc """
  ```elixir
  EctoSchemaless.update!(MyRepo, "my_table", 1, %{name: "Changed Demo"})
  [%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}},
     name: "Changed Demo", updated_at: {{2017, 7, 21}, {14, 56, 14, 903669}}}]
  ```
  """
  @spec update!(Ecto.Repo.t, table_name, id, attribute_set) :: response
  def update!(repo, table_name, id, attributes) do
    attributes = Map.put(attributes, :updated_at, DateTime.utc_now())

    updates =
      attributes
      |> Enum.reduce([], &attribute_to_query/2)
      |> Enum.join(", ")

    sql = "UPDATE #{table_name} SET #{updates} WHERE id = #{id}"

    Ecto.Adapters.SQL.query!(repo, sql)
    select!(repo, "SELECT * FROM #{table_name} WHERE id = #{id}")
  end

  # private

  defp attribute_to_query({column, value}, acc),
    do: ["#{column} = #{stringified(value)}"] ++ acc

  defp row_to_map(columns, row),
    do: [columns, row] |> List.zip |> Enum.into(%{})

  defp stringified(value)
    when is_integer(value) or is_float(value) or is_boolean(value),
    do: value
  defp stringified(%DateTime{} = value), do: "'#{DateTime.to_iso8601(value)}'"
  defp stringified(nil), do: "NULL"
  defp stringified(value), do: "'#{value}'"
end
