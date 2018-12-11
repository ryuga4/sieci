defmodule Sieci.Server.FileSaver do
  @moduledoc false
  


  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    schedule_work(1000)
    {:ok, %{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end



  def schedule_work(time) do
    Process.send_after(self(), :tick, time)
  end

  def handle_info(:tick, state) do
    Agent.update(Sieci.Server.FileEditer, &update_state/1)
    schedule_work(1000)
    {:noreply, state}
  end


  def update_state(state) do
    state
    |> Enum.map(fn {name, i} ->
      if i.changed do
        Sieci.Db.Query.save_file i.file_info
        IO.puts "File #{name} saved"
      end
      {name, %{i | changed: false}}
    end)
    |> Map.new
  end




end