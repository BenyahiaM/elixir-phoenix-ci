defmodule TimeManagerWeb.TeamJSON do
  alias TimeManager.Teams.Team

  @doc """
  Renders a list of team.
  """
  def index(%{team: team}) do
    %{data: for(team <- team, do: data(team))}
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  #Pb lorsqu'on affiche les data, si user vide pb voir ça
  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
    }
  end
end
