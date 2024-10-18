  defmodule TimeManagerWeb.WorkingTimeJSON do
    alias TimeManager.WorkingTimes.WorkingTime

    @doc """
    Renders a list of workingtime.
    """
    def index(%{workingtime: workingtime}) do
      %{data: for(working_time <- workingtime, do: data(working_time))}
    end

    @doc """
    Renders a single working_time.
    """
    def show(%{working_time: working_time}) do
      %{data: data(working_time)}
    end

    defp data(%WorkingTime{} = working_time) do
      %{
        id: working_time.id,
        start: working_time.start,
        end: working_time.end,
        user_id: working_time.user_id
      }
    end
  end
