defmodule Sieci.Client.Client do
  @moduledoc false


  def client do
    {:ok, sock} = :gen_tcp.connect('gentle-crag-95328.herokuapp.com', 3000, [:binary, packet: 0, active: false])

    receive_files(sock)
    handle_client(sock)
  end








  def receive_files(sock) do
    files = recv_length(sock, [])

    IO.inspect(files)
  end


  def recv_length(sock,
        <<length::size(8),
          rest::binary>>) do
    recv_files(length, sock,rest, [])
  end

  def recv_length(sock, bs) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
   #     IO.inspect b
        recv_length(sock, :erlang.list_to_binary([bs,b]))
      {:error, closed} ->
        IO.inspect closed
        {:closed, :erlang.list_to_binary(bs)}
    end
  end

  def recv_files(0,_,_,files), do: files
  def recv_files(length, sock,
    <<t :: size(8),
      ns :: size(8),
      name :: binary-size(ns),
      rest :: binary
     >>, files) do
      recv_files(length - 1 ,sock, rest, [{t, name} | files])
  end


  def recv_files(length, sock, bs, files) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
  #      IO.inspect b
        recv_files(length, sock, :erlang.list_to_binary([bs,b]), files)
      {:error, closed} -> {:closed, :erlang.list_to_binary(bs)}
    end
  end




  def handle_client(sock) do
    path = IO.gets "path: "
    name = String.trim(IO.gets "name: ")
    ns = byte_size name
    t = case Regex.run(~r/\.[^\.]+/, String.trim(path)) do
      [".txt"] -> 1
      [".png"] -> 2
    end
    IO.inspect path
    %{size: cs} = File.stat!(String.trim(path))
    <<content::binary>> = File.read! String.trim(path)
    to_send=<<t::size(8), ns::size(8), cs::size(32)>> <> name <> content
    IO.inspect to_send
    :gen_tcp.send(sock,to_send)
    #:gen_tcp.close(sock)
  end




end
