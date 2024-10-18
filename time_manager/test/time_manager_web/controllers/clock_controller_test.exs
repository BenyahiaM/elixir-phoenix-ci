defmodule TimeManagerWeb.ClockControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.ClocksFixtures
  import TimeManager.UsersFixtures

  alias TimeManager.Clocks.Clock

  @create_attrs %{status: true, time: NaiveDateTime.utc_now()}
  @update_attrs %{status: false, time: NaiveDateTime.utc_now()}
  @invalid_attrs %{status: nil, time: nil, user_id: nil}

  setup do
    user = user_fixture()
    {:ok, user: user}
  end

  describe "index" do
    test "lists all clocks", %{conn: conn} do
      conn = get(conn, ~p"/api/clock")
      assert json_response(conn, 404)["error"] == "No clocks found"
    end
  end

  describe "create clock" do
    test "renders clock when data is valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/clock", clock: Map.put(@create_attrs, :user_id, user.id))
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/clock/#{id}")
      assert %{"id" => ^id, "status" => true} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/clock", clock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update clock" do
    setup [:create_clock]

    test "renders clock when data is valid", %{conn: conn, clock: clock} do
      conn = put(conn, ~p"/api/clock/#{clock.id}", clock: @update_attrs)

      # Au lieu de faire un pattern matching, nous récupérons l'ID et faisons une assertion
      response_data = json_response(conn, 200)["data"]
      assert response_data["id"] == clock.id

      conn = get(conn, ~p"/api/clock/#{clock.id}")
      response_data = json_response(conn, 200)["data"]

      # Vérification que l'ID correspond bien après la mise à jour
      assert response_data["id"] == clock.id
      assert response_data["status"] == false
    end

    test "renders errors when data is invalid", %{conn: conn, clock: clock} do
      conn = put(conn, ~p"/api/clock/#{clock.id}", clock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete clock" do
    setup [:create_clock]

    test "deletes chosen clock", %{conn: conn, clock: clock} do
      conn = delete(conn, ~p"/api/clock/#{clock}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/team/#{clock}")
      assert json_response(conn, 404)["error"] == "Team not found with ID #{clock.id}"
    end
  end

  defp create_clock(_) do
    clock = clock_fixture()
    %{clock: clock}
  end

end
