defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  alias TimeManager.Clocks
  alias TimeManager.Clocks.Clock

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    case Clocks.list_clock() do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clocks found"})

        clocks ->
          conn
          |> put_status(:ok)
          |> render(:index, clock: clocks)
    end
  end

  def create(conn, %{"clock" => clock_params}) do
    if Map.has_key?(clock_params, "time") and Map.has_key?(clock_params, "status") and Map.has_key?(clock_params, "user_id") do
      with {:ok, %Clock{} = clock} <- Clocks.create_clock(clock_params) do
        conn
        |> put_status(:created)
        |> render(:show, clock: clock)
        else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: time, status, user_id"})
    end
  end

  def show(conn, %{"id" => id}) do
    case Clocks.get_clock(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock not found with ID #{id}"})

        clock ->
          render(conn, :show, clock: clock)
    end
  end

  def update(conn, %{"id" => id, "clock" => clock_params}) do
    case Clocks.get_clock(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock  not found with ID #{id}"})

      clock ->
        with {:ok, %Clock{} = clock} <- Clocks.update_clock(clock, clock_params) do
          conn
          |> put_status(:ok)
          |> render(:show, clock: clock)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  def remove(conn, %{"id" => id}) do
    case Clocks.get_clock(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Clock  not found with ID #{id}"})

      clock ->
        with {:ok, %Clock{}} <- Clocks.delete_clock(clock) do
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "Clock supprimé")
        else
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete clock"})
        end
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def swagger_definitions do
    %{
      Clock: swagger_schema do
        title "Clock"
        description "Un enregistrement d'horloge pour un utilisateur (heure d'entrée/sortie)"
        properties do
          id :integer, "Identifiant de l'enregistrement", required: true
          status :boolean, "Indique si l'utilisateur est actuellement clocké", required: true
          time :string, "Heure à laquelle l'utilisateur s'est clocké", format: "date-time", required: true
          user_id :integer, "Identifiant de l'utilisateur associé", required: true
        end
        example %{
          id: 1,
          status: true,
          time: "2024-10-11T08:00:00Z",
          user_id: 1
        }
      end
    }
  end

  # Swagger path to list all clock entries
  swagger_path :index do
    get "/clock"
    summary "Lister tous les enregistrements d'horloge"
    description "Retourne une liste de tous les enregistrements d'horloge pour les utilisateurs."
    response 200, "Succès", Schema.array(:Clock)
  end

  # Swagger path to show a clock entry by ID
  swagger_path :show do
    get "/clock/{id}"
    summary "Afficher un enregistrement d'horloge par ID"
    parameters do
      id(:path, :integer, "ID de l'enregistrement", required: true)
    end
    response 200, "Succès", Schema.ref(:Clock)
    response 404, "Enregistrement non trouvé"
  end

  # Swagger path to create a new clock entry
  swagger_path :create do
    post "/clock"
    summary "Créer un nouvel enregistrement d'horloge"
    parameters do
      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à créer", required: true)
    end
    response 201, "Enregistrement créé", Schema.ref(:Clock)
  end

  # Swagger path to update an existing clock entry
  swagger_path :update do
    put "/clock/{id}"
    summary "Mettre à jour un enregistrement d'horloge par ID"
    parameters do
      id(:path, :integer, "ID de l'enregistrement", required: true)
      clock(:body, Schema.ref(:Clock), "Détails de l'enregistrement d'horloge à mettre à jour", required: true)
    end
    response 200, "Enregistrement mis à jour", Schema.ref(:Clock)
    response 404, "Enregistrement non trouvé"
  end

  # Swagger path to delete a clock entry
  swagger_path :remove do
    delete "/clock/{id}"
    summary "Supprimer un enregistrement d'horloge par ID"
    parameters do
      id(:path, :integer, "ID de l'enregistrement", required: true)
    end
    response 204, "Enregistrement supprimé"
    response 404, "Enregistrement non trouvé"
  end
end
