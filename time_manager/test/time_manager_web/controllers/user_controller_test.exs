defmodule TimeManagerWeb.UserControllerTest do
  use TimeManagerWeb.ConnCase

  import TimeManager.UsersFixtures

  alias TimeManager.Users.User

  @create_attrs %{
    username: "some username",
    email: "some@email",
    password: "password"
  }
  @update_attrs %{
    username: "some updated username",
    email: "some@updatedemail",
    password: "newpassword"
  }
  @invalid_attrs %{username: nil, email: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user", %{conn: conn} do
      conn = get(conn, ~p"/api/user")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/user/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some@email",
               "username" => "some username",
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when missing data", %{conn: conn} do
      conn = post(conn, ~p"/api/user", user: %{})
      assert json_response(conn, 400)["error"] == "Missing required fields: email, username and password"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/user/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/user/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some@updatedemail",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/user/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/user/#{user}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/team/#{user}")
      assert json_response(conn, 404)["error"] == "Team not found with ID #{user.id}"
    end
  end

  #
  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
