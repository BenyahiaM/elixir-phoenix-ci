defmodule TimeManagerWeb.SessionController do
  use TimeManagerWeb, :controller
  alias TimeManager.Repo
  alias TimeManager.Users.User
  alias TimeManagerWeb.Auth.Guardian

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = Repo.get_by(User, email: email)

    if user && Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, %{})
      conn
      |> put_status(:ok)
      |> json(%{jwt: jwt})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid email or password"})
    end
  end
end
