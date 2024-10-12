defmodule TimeManagerWeb.Auth.Guardian do
  use Guardian, otp_app: :time_manager

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    user = TimeManager.Repo.get(TimeManager.Users.User, id)
    {:ok, user}
  end
end
