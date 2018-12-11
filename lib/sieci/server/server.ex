defmodule Sieci.Server.Server do
  @moduledoc false
  use Supervisor


  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end


  def init(_) do
    children = [
      worker(Sieci.Server.FileReceiver, [name: FileReceiver]),
      worker(Sieci.Server.FileEditer, [name: FileEditer]),
      worker(Sieci.Server.FileSaver, [name: FileSaver])
    ]
	
    IO.puts "Start"
	
    Supervisor.init(children, strategy: :one_for_one)
  end


end
