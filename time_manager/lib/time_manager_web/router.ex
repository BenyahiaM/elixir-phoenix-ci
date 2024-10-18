defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TimeManagerWeb.Plugs.AuthPipeline
  end


  scope "/api", TimeManagerWeb do
    pipe_through [:api, :authenticated]

    get "/protected_route", ProtectedController, :index
  end

  scope "/api", TimeManagerWeb do
    pipe_through :api

    get "/user", UserController, :filter
    get "/user/:userID", UserController, :show
    post "/user", UserController, :create
    put "/user/:id", UserController, :update
    put "/user/:id/:team_id", UserController, :assign_to_team
    delete "/user/:userID", UserController, :remove

    get "/clock", ClockController, :index
    get "/clock/:id", ClockController, :show
    post "/clock", ClockController, :create
    put "/clock/:id", ClockController, :update
    delete "/clock/:id", ClockController, :remove

    get "/workingtime", WorkingTimeController, :index
    get "/workingtime/:id", WorkingTimeController, :show
    get "/workingtime?userID", WorkingTimeController, :index_by_user
    get "/workingtime/:userID/:id", WorkingTimeController, :show_by_user
    post "/workingtime", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :remove
    delete "/workingtime/:id", WorkingTimeController, :delete
    resources "/sessions", SessionController, only: [:create]


    get "/team", TeamController, :index
    get "/team/:id", TeamController, :show
    post "/team", TeamController, :create
    put "/team/:id", TeamController, :update
    delete "team/:id", TeamController, :remove

    resources "/sessions", SessionController, only: [:create]

    def swagger_info do
      %{
        info: %{
          version: "1.0",
          title: "Time Manager"
        },
        host: "localhost:4000",     # Définit le domaine et le port de base
        basePath: "/api",           # Définit le chemin de base de toutes les routes
        schemes: ["http"]           # Définit les protocoles supportés
      }
    end
  end
  
  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :time_manager, swagger_file: "swagger.json"
  end
end
