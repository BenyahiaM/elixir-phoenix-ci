defmodule TimeManagerWeb.WorkingTimeControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.WorkingTimesFixtures
  import TimeManager.UsersFixtures

  alias TimeManager.WorkingTimes.WorkingTime

  @create_attrs %{
    start: ~U[2024-10-07 09:22:00Z],
    end: ~U[2024-10-07 09:22:00Z]
  }
  @update_attrs %{
    start: ~U[2024-10-08 09:22:00Z],
    end: ~U[2024-10-08 09:22:00Z],
  }
  @invalid_attrs %{start: nil, end: nil, user_id: nil}

  setup do
    user = user_fixture()
    {:ok, user: user}
  end

  describe "index" do
    test "lists all workingtime", %{conn: conn} do
      conn = get(conn, ~p"/api/workingtime")
      assert json_response(conn, 404)["error"] == "No working times found"
    end
  end

  describe "create working_time" do
    test "renders working_time when data is valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/workingtime", working_time: Map.put(@create_attrs, :user_id, user.id))
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/workingtime/#{id}")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/workingtime", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update working_time" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/workingtime/#{working_time.id}", working_time: @update_attrs)

      response_data = json_response(conn, 200)["data"]
      assert response_data["id"] == working_time.id

      conn = get(conn, ~p"/api/workingtime/#{working_time.id}")
      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == working_time.id
      assert response_data["start"] == "2024-10-08T09:22:00Z"
      assert response_data["end"] == "2024-10-08T09:22:00Z"
    end

    test "renders errors when data is invalid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/workingtime/#{working_time.id}", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete working_time" do
    setup [:create_working_time]

    test "deletes chosen working_time", %{conn: conn, working_time: working_time} do
      conn = delete(conn, ~p"/api/workingtime/#{working_time}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/workingtime/#{working_time}")
      assert json_response(conn, 404)["error"] == "Working time not found with ID #{working_time.id}"
    end
  end

  defp create_working_time(_) do
    working_time = working_time_fixture()
    %{working_time: working_time}
  end
end
