defmodule Sieci.Client.Client2 do
  @moduledoc false
  def client do
    {:ok, sock} = :gen_tcp.connect('localhost', 3001, [:binary, packet: 0, active: false])
    name = String.trim(IO.gets("name: "))
    size = byte_size name
    to_send = <<0::size(8), size::size(8)>> <> name
    :gen_tcp.send(sock,to_send)
    Task.async(fn -> loop(sock, []) end)
    #update_content sock, name, "2"
    sock
  end

  def client2 do
    {:ok, sock} = :gen_tcp.connect('localhost', 3001, [:binary, packet: 0, active: false])
    name = String.trim(IO.gets("name: "))
    size = byte_size name
    to_send = <<0::size(8), size::size(8)>> <> name
    :gen_tcp.send(sock,to_send)
    Task.async(fn -> loop(sock, []) end)
    update_content sock, name, "3"
    sock
  end

  def loop(sock, bs) do
    {content, rest} = recv_content(sock, bs)
    IO.inspect sock
    IO.puts content
    loop(sock, rest)
  end

  def recv_content(sock,
        <<ns::size(8),
          content::binary-size(ns),
          rest :: binary>>) do
    {content, rest}
  end

  def recv_content(sock, bs) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
        #     IO.inspect b
        recv_content(sock, :erlang.list_to_binary([bs,b]))
      {:error, closed} ->
        IO.inspect closed
        {:closed, :erlang.list_to_binary(bs)}
    end
  end




  def update_content(sock, name, content) do
    cs = byte_size content
    ns = byte_size  name
    to_send = <<1::size(8), ns::size(8), cs::size(32)>> <> name <> content
    :gen_tcp.send(sock,to_send)
  end
end
