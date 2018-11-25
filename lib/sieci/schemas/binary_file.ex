defmodule Sieci.Schemas.BinaryFile do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset


  schema "files" do
    field :filename
    field :type
    field :content, :binary

    timestamps()
  end


  @required_fields [:filename, :type, :content]
  @optional_fields []

  def changeset(file, params \\ :empty) do
    file
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:filename)

  end

end
