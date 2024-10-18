defmodule TimeManager.Repo.Migrations.ModifyUserTable do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :is_manager, :boolean, default: false
      add :is_general_manager, :boolean, default: false
      add :password_hash, :string
      add :team_id, references(:team, on_delete: :nilify_all)
    end
  end
end