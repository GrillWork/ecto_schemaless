# EctoSchemaless

`EctoSchemaless` is a very simple module designed to make interacting with
`Ecto.Repo`s easier.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_schemaless` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ecto_schemaless, "~> 0.1.0"}]
end
```

## Usage

Note: `insert` and `update` currently only work with tables that have the
`inserted_at` and `updated_at` columns.

```elixir
EctoSchemaless.insert!(MyRepo, "my_table", %{name: "Demo"})
[%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}}, name: "Demo",
   updated_at: {{2017, 7, 21}, {14, 49, 34, 124176}}}]
```

```elixir
EctoSchemaless.select!(MyRepo, "SELECT * FROM my_table WHERE id = 1")
[%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}}, name: "Demo",
   updated_at: {{2017, 7, 21}, {14, 49, 34, 124176}}}]
```

```elixir
EctoSchemaless.update!(MyRepo, "my_table", 1, %{name: "Changed Demo"})
[%{id: 1, inserted_at: {{2017, 7, 21}, {14, 49, 34, 124176}},
   name: "Changed Demo", updated_at: {{2017, 7, 21}, {14, 56, 14, 903669}}}]
```

```elixir
EctoSchemaless.delete!(MyRepo, "DELETE FROM my_table WHERE id = 1")
%Postgrex.Result{columns: nil, command: :delete, connection_id: 57048,
 num_rows: 1, rows: nil}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_schemaless](https://hexdocs.pm/ecto_schemaless).
