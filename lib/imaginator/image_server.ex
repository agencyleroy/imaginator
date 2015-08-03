defmodule Placeholder.Imaginator do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def process(server, opts={_params}) do
    GenServer.cast(server, {:process, opts})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  ## Server Callbacks
  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_cast({:process, {_params}}, state) do
    {:ok, img} = convert(_params)
    {:noreply, HashDict.put(state, :image, img.path)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, HashDict.get(state, key), state}
  end

  def convert(_params) do
    Placeholder.Generator.render_image(_params)
  end

end