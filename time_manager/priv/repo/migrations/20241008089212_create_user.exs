defmodule TimeManager.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_hash, :string
      add :is_manager, :boolean, default: false
      add :is_general_manager, :boolean, default: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
