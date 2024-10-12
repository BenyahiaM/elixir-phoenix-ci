defmodule TimeManager.Repo.Migrations.AddTeamUser do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :team_id, references(:team, on_delete: :nilify_all)
    end
  end
end
