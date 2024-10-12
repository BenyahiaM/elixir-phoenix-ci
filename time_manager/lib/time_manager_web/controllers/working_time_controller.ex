defmodule TimeManagerWeb.WorkingTimeController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  import Ecto.Query
  alias TimeManager.WorkingTimes
  alias TimeManager.WorkingTimes.WorkingTime
  alias TimeManager.Repo
  alias TimeManagerWeb.WorkingTimeJSON

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    workingtime = WorkingTimes.list_workingtime()
    render(conn, :index, workingtime: workingtime)
  end

  def create(conn, %{"working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <- WorkingTimes.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> render(:show, working_time: working_time)
    end
  end

  def show(conn, %{"id" => id}) do
    working_time = WorkingTimes.get_working_time!(id)
    render(conn, :show, working_time: working_time)
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    working_time = WorkingTimes.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <- WorkingTimes.update_working_time(working_time, working_time_params) do
      render(conn, :show, working_time: working_time)
    end
  end

  def remove(conn, %{"id" => id}) do
    working_time = WorkingTimes.get_working_time!(id)

    with {:ok, %WorkingTime{}} <- WorkingTimes.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end

  # Nouvelle action pour gérer la requête GET /workingtime/:userID/:id
  def show_by_user(conn, %{"userID" => user_id, "id" => workingtime_id}) do
    # Recherche du workingtime pour l'utilisateur donné
    case Repo.get_by(WorkingTime, user_id: user_id, id: workingtime_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      working_time ->
        conn
        |> put_status(:ok)
        |> json(WorkingTimeJSON.show(%{working_time: working_time}))  # Utilise WorkingTimeJSON pour encoder la réponse
    end
  end

  def index_by_user(conn, %{"userID" => user_id}) do
    start_time = conn.query_params["start"]
    end_time = conn.query_params["end"]

    working_times =
      WorkingTime
      |> where(user_id: ^user_id)
      |> filter_by_time_range(start_time, end_time)
      |> Repo.all()

    conn
    |> put_status(:ok)
    |> json(WorkingTimeJSON.index(%{workingtime: working_times}))
  end

  defp filter_by_time_range(query, nil, nil), do: query

  defp filter_by_time_range(query, start_time, nil) do
    case DateTime.from_iso8601(start_time) do
      {:ok, start_datetime, _} ->
        from(w in query, where: w.start >= ^start_datetime)

      {:error, _} ->
        query  # ou tu pourrais lever une erreur si la conversion échoue
    end
  end

  defp filter_by_time_range(query, nil, end_time) do
    case DateTime.from_iso8601(end_time) do
      {:ok, end_datetime, _} ->
        from(w in query, where: w.end <= ^end_datetime)

      {:error, _} ->
        query  # ou lever une erreur
    end
  end

  defp filter_by_time_range(query, start_time, end_time) do
    case {DateTime.from_iso8601(start_time), DateTime.from_iso8601(end_time)} do
      {{:ok, start_datetime, _}, {:ok, end_datetime, _}} ->
        from(w in query,
          where: w.start >= ^start_datetime and w.end <= ^end_datetime
        )

      _ ->
        query  # ou lever une erreur si la conversion échoue
    end
  end

  # Swagger schema definition for WorkingTime
  def swagger_definitions do
    %{
      WorkingTime: swagger_schema do
        title "WorkingTime"
        description "Un enregistrement des heures de travail d'un utilisateur"
        properties do
          id :integer, "Identifiant du temps de travail", required: true
          start_time :string, "Heure de début du travail", format: "date-time", required: true
          end_time :string, "Heure de fin du travail", format: "date-time", required: true
          user_id :integer, "Identifiant de l'utilisateur associé", required: true
        end
      end
    }
  end

  # Swagger path to list all working times
  swagger_path :index do
    get "/workingtime"
    summary "Lister tous les temps de travail"
    description "Retourne une liste de tous les temps de travail."
    response 200, "Succès", Schema.array(:WorkingTime)
  end

  # Swagger path to list working times by user
  swagger_path :index_by_user do
    get "/workingtime/{userID}"
    summary "Lister les temps de travail d'un utilisateur"
    parameters do
      userID(:path, :integer, "ID de l'utilisateur", required: true)
    end
    response 200, "Succès", Schema.array(:WorkingTime)
    response 404, "Utilisateur non trouvé"
  end

  # Swagger path to show a specific working time for a user
  swagger_path :show_by_user do
    get "/workingtime/{userID}/{id}"
    summary "Afficher un temps de travail par ID pour un utilisateur"
    parameters do
      userID(:path, :integer, "ID de l'utilisateur", required: true)
      id(:path, :integer, "ID du temps de travail", required: true)
    end
    response 200, "Succès", Schema.ref(:WorkingTime)
    response 404, "Temps de travail ou utilisateur non trouvé"
  end

  # Swagger path to create a new working time
  swagger_path :create do
    post "/workingtime"
    summary "Créer un nouveau temps de travail"
    parameters do
      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à créer", required: true)
    end
    response 201, "Temps de travail créé", Schema.ref(:WorkingTime)
  end

  # Swagger path to update an existing working time
  swagger_path :update do
    put "/workingtime/{id}"
    summary "Mettre à jour un temps de travail par ID"
    parameters do
      id(:path, :integer, "ID du temps de travail", required: true)
      working_time(:body, Schema.ref(:WorkingTime), "Détails du temps de travail à mettre à jour", required: true)
    end
    response 200, "Temps de travail mis à jour", Schema.ref(:WorkingTime)
    response 404, "Temps de travail non trouvé"
  end

  # Swagger path to delete a working time
  swagger_path :remove do
    delete "/workingtime/{id}"
    summary "Supprimer un temps de travail par ID"
    parameters do
      id(:path, :integer, "ID du temps de travail", required: true)
    end
    response 204, "Temps de travail supprimé"
    response 404, "Temps de travail non trouvé"
  end
end
