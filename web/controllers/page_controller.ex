defmodule Imaginator.PageController do
  use Imaginator.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
