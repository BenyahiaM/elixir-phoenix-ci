defmodule TimeManager.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TimeManager.Users` context.
  """

  def user_fixture(attrs \\ %{}) do
    unique_email = "some#{System.unique_integer([:positive])}@email.com"
    unique_username = "username#{System.unique_integer([:positive])}"
    unique_password = "password#{System.unique_integer([:positive])}"


    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_email,
        username: unique_username,
        password: unique_password,
      })
      |> TimeManager.Users.create_user()

    user
  end
end
