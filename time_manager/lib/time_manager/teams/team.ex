defmodule TimeManager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias TimeManager.Users.User

  schema "team" do
    field :name, :string
    has_many :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end


end
