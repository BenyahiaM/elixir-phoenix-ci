defmodule TimeManager.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt

  schema "user" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :is_manager, :boolean, default: false
    field :is_general_manager, :boolean, default: false
    field :password, :string, virtual: true
    belongs_to :team, Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :is_manager, :is_general_manager, :password, :team_id])
    |> validate_required([:username, :email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
    |> validate_manager_exclusivity()  # Ajout de la validation personnalisée
    |> put_password_hash()
  end

  defp validate_manager_exclusivity(changeset) do
    is_manager = get_field(changeset, :is_manager)
    is_general_manager = get_field(changeset, :is_general_manager)

    if is_manager && is_general_manager do
      add_error(changeset, :is_manager, "Cannot be both a manager and a general manager.")
    else
      changeset
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end