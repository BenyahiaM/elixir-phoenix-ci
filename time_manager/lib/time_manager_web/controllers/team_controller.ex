defmodule TimeManagerWeb.TeamController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  alias TimeManager.Teams
  alias TimeManager.Teams.Team
  alias TimeManager.Repo


  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    case Teams.list_team() do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No teams found"})

      teams ->
        conn
        |> put_status(:ok)
        |> render(:index, team: teams)
    end
  end

  def create(conn, %{"team" => team_params}) do
    if Map.has_key?(team_params, "name") do
      with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
        conn
        |> put_status(:created)
        |> render(:show, team: team)
      else
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: translate_errors(changeset)})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Missing required fields: name"})
    end
  end

  def show(conn, %{"id" => id}) do
    case Teams.get_team(id) |> Repo.preload(:user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found with ID #{id}"})

      team ->
        conn
        |> put_status(:ok)
        |> render(:show, team: team)
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    case Teams.get_team(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found with ID #{id}"})

      team ->
        with {:ok, %Team{} = updated_team} <- Teams.update_team(team, team_params) do
          conn
          |> put_status(:ok)
          |> render(:show, team: updated_team)
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  def remove(conn, %{"id" => id}) do
    case Teams.get_team(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found with ID #{id}"})

      team ->
        with {:ok, %Team{}} <- Teams.delete_team(team) do
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "")
        else
          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to delete team"})
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

  # Swagger schema definition for Team
  def swagger_definitions do
    %{
      Team: swagger_schema do
        title "Team"
        description "Une équipe de l'application"
        properties do
          id :integer, "Identifiant de l'équipe", required: true
          name :string, "Nom de l'équipe", required: true
        end
        example %{
          id: 1,
          name: "Développeurs"
        }
      end
    }
  end

  # Swagger path to list all teams
  swagger_path :index do
    get "/team"
    summary "Lister toutes les équipes"
    description "Retourne une liste de toutes les équipes."
    response 200, "Succès", Schema.array(:Team)
  end

  # Swagger path to show a team by ID
  swagger_path :show do
    get "/team/{id}"
    summary "Afficher une équipe par ID"
    parameters do
      id(:path, :integer, "ID de l'équipe", required: true)
    end
    response 200, "Succès", Schema.ref(:Team)
    response 404, "Équipe non trouvée"
  end

  # Swagger path to create a new team
  swagger_path :create do
    post "/team"
    summary "Créer une nouvelle équipe"
    parameters do
      team(:body, Schema.ref(:Team), "Détails de l'équipe à créer", required: true)
    end
    response 201, "Équipe créée", Schema.ref(:Team)
  end

  # Swagger path to update an existing team
  swagger_path :update do
    put "/team/{id}"
    summary "Mettre à jour une équipe par ID"
    parameters do
      id(:path, :integer, "ID de l'équipe", required: true)
      team(:body, Schema.ref(:Team), "Détails de l'équipe à mettre à jour", required: true)
    end
    response 200, "Équipe mise à jour", Schema.ref(:Team)
    response 404, "Équipe non trouvée"
  end

  # Swagger path to delete a team
  swagger_path :remove do
    delete "/team/{id}"
    summary "Supprimer une équipe par ID"
    parameters do
      id(:path, :integer, "ID de l'équipe", required: true)
    end
    response 204, "Équipe supprimée"
    response 404, "Équipe non trouvée"
  end
end
