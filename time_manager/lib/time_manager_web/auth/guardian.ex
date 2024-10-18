defmodule TimeManagerWeb.Auth.Guardian do
  use Guardian, otp_app: :time_manager
  alias TimeManager.Users

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    IO.inspect(id, label: "User ID from claims")
    case Users.get_user(id) do
      nil ->
        Logger.error("User not found for ID: #{id}")
        {:error, :resource_not_found}
      user ->
        IO.inspect(user, label: "User found")
        {:ok, user}
    end
  end
end
