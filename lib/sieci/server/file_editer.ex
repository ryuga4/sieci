defmodule Sieci.Server.FileEditer do
  @moduledoc false
  alias Sieci.Repo
  alias Sieci.Schemas.BinaryFile
  use Agent





  def start_link(x) do

    case :gen_tcp.listen(3001, [:binary, packet: 0, active: false, reuseaddr: true]) do
      {:ok, lsock} ->
        Task.async(fn -> queue(lsock) end)
        Agent.start_link(fn -> %{} end, name: __MODULE__)
      {:error, :eaddrinuse} ->
        IO.puts "Addres in use"
        :timer.sleep(1000)
        #System.cmd("fuser" , ["-k", "3001/tcp"])
        start_link(x)
    end

  end

  def queue(lsock) do
    {:ok, sock} = :gen_tcp.accept(lsock)
    IO.puts "Editer connected"
    {name, rest} = recv_name(sock, [])
    Agent.update(__MODULE__, fn state -> add_sock(sock,name,state) end)
    content = Agent.get(__MODULE__, fn state -> Map.get(state,name).content end)


    cs = byte_size content

    :gen_tcp.send(sock, <<cs::size(32)>> <> content)
    Task.async(fn -> recv_changes(sock, []) end)
    queue(lsock)
  end




  def recv_changes(sock,
        <<1::size(8),
          ns::size(8),
          cs::size(32),
          name::binary-size(ns),
          content::binary-size(cs),
          rest::binary>>) do
      Agent.update(__MODULE__, fn state -> change_content(state, name,content) end)

      recv_changes(sock, rest)
  end

  def recv_changes(sock, bs) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
        recv_changes(sock, :erlang.list_to_binary([bs,b]))
      {:error, closed} ->
        {:closed, bs}
    end
  end

  def recv_name(sock, <<0::size(8), ns::size(8), name::binary-size(ns),rest::binary>>) do
    #IO.puts name
    {name, rest}
  end

  def recv_name(sock, bs) do
    case :gen_tcp.recv(sock, 0) do
      {:ok, b} ->
        recv_name(sock, :erlang.list_to_binary([bs,b]))
      {:error, closed} -> {:closed, :erlang.list_to_binary(bs)}
    end
  end


  def add_sock(sock, name, state) do
    #IO.puts "ADD"
    c = hd(Sieci.Db.Query.get_content(name))
    Map.update(state, name, %{socks: [sock], content: c}, fn x -> %{x | socks: [sock|x.socks]} end)
  end


  def change_content(state, name, content) do

    Map.update(state, name, %{socks: [], content: content},
      fn %{socks: socks} ->
        
        socks2 = Enum.reduce(socks, [], fn s, acc ->
         
          case send_change(s,content) do
            :ok -> [s|acc]
            _ -> acc
          end
        end)
        %{socks: socks2, content: content}

      end
    )



  end

  def send_change(sock, content) do
    #IO.puts "Sending change"
    

    cs = byte_size content
    toSend = <<cs::size(32)>> <> content

    :gen_tcp.send(sock, toSend)
  end


  def handle_info(a,b) do
    
  end

end
