defmodule Sieci.Server.FileReceiver do
  @moduledoc false

  alias Sieci.Repo
  alias Sieci.Schemas.BinaryFile
  use GenServer



  def start_link(opts) do
   # IO.inspect opts
   GenServer.start_link(__MODULE__, nil)
  end


  def init(_) do

    case :gen_tcp.listen(3000, [:binary, packet: 0, active: false, reuseaddr: true]) do
      {:ok, lsock} ->
        Task.async(fn -> queue(lsock) end)
        {:ok, []}
      {:error, :eaddrinuse} ->
        IO.puts "Addres in use"
        :timer.sleep(1000)
        System.cmd("fuser" , ["-k", "3000/tcp"])
        init(nil)
    end

  end

  def queue(lsock) do
    {:ok, sock} = :gen_tcp.accept(lsock)
    IO.puts "Server: Connected"
    send_files(sock)
    Task.async(fn -> handle(sock) end)
    queue(lsock)
  end



  def send_files(sock) do
    files = Sieci.Db.Query.get_descriptions()
    mapped = Enum.map files, fn {filename, type} ->
      type_id = case type do
        "txt" -> 1
        "png" -> 2
      end

      name_size = byte_size filename
      <<type_id :: size(8), name_size :: size(8)>> <> filename
    end
    length = Enum.count mapped

    to_send = <<length::size(8)>> <> Enum.reduce(mapped, fn (a,acc) -> acc<>a end)
    IO.puts "Server: "
    IO.inspect mapped
    :gen_tcp.send(sock, to_send)
  end


  def handle(sock) do
    case recv(sock,[]) do
      {:ok,t,name,content,rest} ->
        type = case t do
          1 -> "txt"
          2 -> "png"
        end


        changeset = BinaryFile.changeset(%BinaryFile{},
          %{filename: name,
            type: type,
            content: content
          })

        case Repo.insert(changeset) do
          {:ok, record} -> nil
          {:error, changeset} -> nil
        end

        handle(sock)
      {:closed, x} ->
        IO.puts "Server: Closed"

    end
  end

  def recv(sock,
        <<t::size(8),
          ns::size(8),
          cs::size(32),
          name::binary-size(ns),
          content::binary-size(cs),
          rest::binary>>) do
    {:ok, t, name, content, rest}
  end

  def recv(sock, bs) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
        IO.inspect b
        recv(sock, :erlang.list_to_binary([bs,b]))
      {:error, closed} -> {:closed, :erlang.list_to_binary(bs)}
    end
  end


  def handle_call(_, _from, state) do
    {:reply, nil, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end



end
