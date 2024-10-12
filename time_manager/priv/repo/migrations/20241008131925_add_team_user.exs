defmodule TimeManager.Repo.Migrations.AddTeamUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists(:team_id, :integer)
    end
  end
end
