defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  use PhoenixSwagger

  import Ecto.Query
  alias TimeManager.Users
  alias TimeManager.Users.User
  alias TimeManagerWeb.UserJSON
  alias TimeManager.Teams.Team
  alias TimeManager.Repo

  action_fallback TimeManagerWeb.FallbackController

  def index(conn, _params) do
    user = Users.list_user()
    render(conn, :index, user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"userID" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def assign_to_team(conn, %{"id" => user_id, "team_id" => team_id}) do
    # Récupérer l'utilisateur et l'équipe par ID
    user = Repo.get(User, user_id)
    team = Repo.get(Team, team_id)

    # Vérifier si l'utilisateur et l'équipe existent
    cond do
      is_nil(user) ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      is_nil(team) ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      true ->
        # Mettre à jour l'utilisateur avec la nouvelle équipe
        changeset = User.changeset(user, %{team_id: team.id})

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(UserJSON.show_user(%{user: updated_user}))

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: changeset.errors})
        end
    end
  end

  def remove(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def filter(conn, %{"email" => email, "username" => username, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.email == ^email and u.username == ^username and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"email" => email, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.email == ^email and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"username" => username, "team_id" => team_id}) do
    users =
      User
      |> where([u], u.username == ^username and u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"team_id" => team_id}) do
    users =
      User
      |> where([u], u.team_id == ^team_id)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"email" => email}) do
    users =
      User
      |> where([u], u.email == ^email)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, %{"username" => username}) do
    users =
      User
      |> where([u], u.username == ^username)
      |> Repo.all()

    render_users(conn, users)
  end

  def filter(conn, _params) do
    users = Repo.all(User)

    render_users(conn, users)
  end

  defp render_users(conn, user) do
    conn
    |> put_status(:ok)
    |> json(UserJSON.index(%{user: user}))
  end

  def swagger_definitions do
    %{
      User: swagger_schema do
        title "User"
        description "A user of the application"
        properties do
          id :integer, "Identifiant", required: true
          username :string, "Pseudonyme", required: true
          email :string, "Adresse mail", required: true
          is_manager :boolean, "Est un manager"
          is_general_manager :boolean, "Est un directeur"
          team_id :integer, "Identifiant de son équipe"
        end
      end,
    }
  end

  swagger_path :index do
    get "/user"
    summary "Lister tous les utilisateurs"
    description "Retourne une liste de tous les utilisateurs."
    response 200, "Succès", Schema.ref(:User)
  end

  swagger_path :create do
    post "/user"
    summary "Créer un nouvel utilisateur"
    parameters do
      user(:body, Schema.ref(:User), "Détails de l'utilisateur à créer", required: true)
    end
    response 201, "Utilisateur créé", Schema.ref(:User)
  end

  swagger_path :show do
    get "/user/{userID}"
    summary "Afficher un utilisateur par ID"
    parameters do
      userID(:path, :integer, "ID de l'utilisateur", required: true)
    end
    response 200, "Utilisateur trouvé", Schema.ref(:User)
    response 404, "Utilisateur non trouvé"
  end

  swagger_path :update do
    put "/user/{id}"
    summary "Mettre à jour un utilisateur par ID"
    parameters do
      id(:path, :integer, "ID de l'utilisateur", required: true)
      user(:body, Schema.ref(:User), "Détails de l'utilisateur à mettre à jour", required: true)
    end
    response 200, "Utilisateur mis à jour", Schema.ref(:User)
    response 404, "Utilisateur non trouvé"
  end

  swagger_path :assign_to_team do
    put "/user/{id}/{team_id}"
    summary "Assigner un utilisateur à une équipe"
    parameters do
      id(:path, :integer, "ID de l'utilisateur", required: true)
      team_id(:path, :integer, "ID de l'équipe", required: true)
    end
    response 200, "Utilisateur assigné à l'équipe"
    response 404, "Utilisateur ou équipe non trouvés"
  end

  swagger_path :remove do
    delete "/user/{id}"
    summary "Supprimer un utilisateur par ID"
    parameters do
      id(:path, :integer, "ID de l'utilisateur", required: true)
    end
    response 204, "Utilisateur supprimé"
    response 404, "Utilisateur non trouvé"
  end

  swagger_path :filter do
    get "/user"
    summary "Filtrer les utilisateurs"
    parameters do
      email(:query, :string, "Email de l'utilisateur")
      username(:query, :string, "Nom d'utilisateur")
      team_id(:query, :integer, "ID de l'équipe")
    end
    response 200, "Liste des utilisateurs filtrés", Schema.ref(:User)
  end
end
