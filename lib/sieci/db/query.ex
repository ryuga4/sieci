defmodule Sieci.Db.Query do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Sieci.Repo
  alias Sieci.Schemas.BinaryFile



  def get_all() do
    query = from x in BinaryFile,
            select: x

    Repo.all(query)
  end

  def get_descriptions() do
    query = from x in BinaryFile,
            select: {x.filename, x.type}
    Repo.all(query)
  end


  def get_content(name) do
    query = from x in BinaryFile,
              where: x.filename == ^name,
              select: x.content

    Repo.all(query)
  end
end
