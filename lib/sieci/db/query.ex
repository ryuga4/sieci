defmodule Sieci.Db.Query do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias Sieci.Repo
  alias Sieci.Schemas.BinaryFile



  def get_all() do
    Path.wildcard("resources/*")
    |> Enum.map(&get_file/1)

  end

  def get_descriptions() do
    get_all()
    |> Enum.map(fn x -> {x.filename, x.type} end)
  end


  def get_content(name) do
    Path.wildcard("resources/"<>name<>"*")
    |> hd
    |> File.read!
  end



  def save_file(%{filename: name, type: type, content: content}) do
    File.write!("resources/"<>name<>type, content)
  end



  def get_file(path) do
    [_, name] = Regex.run ~r/(.*)\..*/, Path.basename(path)
    type = Path.extname(path)
    content = File.read!(path)
    %{filename: name, type: type, content: content}
  end


  defp get_description()
end
