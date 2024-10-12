defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api", TimeManagerWeb do
    pipe_through :api

    get "/user", UserController, :filter
    get "/user/:userID", UserController, :show
    post "/user", UserController, :create
    put "/user/:id", UserController, :update
    put "/user/:id/:team_id", UserController, :assign_to_team
    delete "/user/:userID", UserController, :remove

    resources "/clock", ClockController, expect: [:new, :edit]

    get "/workingtime", WorkingTimeController, :index
    get "/workingtime/:userID", WorkingTimeController, :index_by_user
    get "/workingtime/:userID/:id", WorkingTimeController, :show_by_user
    post "/workingtime", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :remove
    delete "/workingtime/:id", WorkingTimeController, :delete
    resources "/sessions", SessionController, only: [:create]


    resources "/team", TeamController, expect: [:new, :edit]

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
