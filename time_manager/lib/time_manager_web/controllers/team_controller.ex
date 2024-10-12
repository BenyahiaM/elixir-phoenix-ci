defmodule TimeManagerWeb.TeamController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  alias TimeManager.Teams
  alias TimeManager.Teams.Team
  alias TimeManager.Repo


  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    team = Teams.list_team()
    render(conn, :index, team: team)
  end

  def create(conn, %{"team" => team_params}) do
    case Teams.create_team(team_params) do
      {:ok, %Team{} = team} ->
        conn
        |> put_status(:created)
        |> render(:show, team: team)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Teams.get_team!(id) |> Repo.preload(:user)

    # Vérifie si un user est associé à l'équipe
    if is_nil(team.user) do
      render(conn, :show, team: team)  # Si pas d'utilisateur, utilise la fonction show
    else
      render(conn, :show_user, team: team)  # Si un utilisateur est présent, utilise show_user
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
      render(conn, :show, team: team)
    end
  end

  def remove(conn, %{"id" => id}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{}} <- Teams.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
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
