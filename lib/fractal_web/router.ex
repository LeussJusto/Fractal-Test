defmodule FractalWeb.Router do
  use FractalWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug FractalWeb.GraphQL.Context
  end

  scope "/api" do
    pipe_through :api

    # GraphQL endpoint
    forward "/graphql",
            Absinthe.Plug,
            schema: FractalWeb.GraphQL.Schema

    # GraphiQL IDE (solo en desarrollo)
    if Mix.env() == :dev do
      forward "/graphiql",
              Absinthe.Plug.GraphiQL,
              schema: FractalWeb.GraphQL.Schema,
              interface: :playground
    end
  end
end
