defmodule TimeManager.Repo.Migrations.CreateClock do
  use Ecto.Migration

  def change do
    create table(:clock) do
      add :time, :naive_datetime
      add :status, :boolean, default: false, null: false
      add :user_id, references(:user, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:clock, [:user_id])
  end
end
