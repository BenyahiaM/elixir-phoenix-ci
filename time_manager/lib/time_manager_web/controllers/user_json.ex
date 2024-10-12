defmodule TimeManagerWeb.UserJSON do
  alias TimeManager.Users.User

  @doc """
  Renders a list of user.
  """
  def index(%{user: user}) do
    %{data: for(user <- user, do: data(user))}
  end

  def index_team(%{user: user}) do
    %{data: for(user <- user, do: data_user(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      is_manager: user.is_manager,
      is_general_manager: user.is_general_manager,
      password_hash: user.password_hash
    }
  end

  def show_user(%{user: user}) do
    %{data: data_user(user)}
  end

  defp data_user(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      is_manager: user.is_manager,
      is_general_manager: user.is_general_manager,
      team_id: user.team_id
    }
  end
end
