defmodule Sieci.Repo.Migrations.BinaryFile do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string, unique: true
      add :type, :string, default: "txt"
      add :content, :binary

      timestamps()
    end


    create(unique_index(:files, [:filename], name: :unique_filenames))
  end
end
