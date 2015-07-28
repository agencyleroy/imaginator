defmodule Imaginator.Router do
  use Imaginator.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    #plug :fetch_session
    #plug :fetch_flash
    #plug :protect_from_forgery
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  scope "/", Imaginator do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/:width/:height", ImageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", Imaginator do
  #   pipe_through :api
  # end
end
