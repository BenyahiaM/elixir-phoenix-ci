defmodule TimeManager.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:team) do
      add :name, :string
      add :user_id, references(:user, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end
  end
end
