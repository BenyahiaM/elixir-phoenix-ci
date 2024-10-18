defmodule TimeManager.ClocksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TimeManager.Clocks` context.
  """

  @doc """
  Generate a clock.
  """
  alias TimeManager.UsersFixtures

  def clock_fixture(attrs \\ %{}) do
    user = UsersFixtures.user_fixture()

    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2024-10-07 09:04:00],
        user_id: user.id
      })
      |> TimeManager.Clocks.create_clock()

    clock
  end
end
