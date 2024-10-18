defmodule TimeManager.UsersTest do
  use TimeManager.DataCase

  alias TimeManager.Users

  describe "user" do
    alias TimeManager.Users.User

    import TimeManager.UsersFixtures

    @invalid_attrs %{username: nil, email: nil}

    test "list_user/0 returns all users" do
      user = user_fixture()
      assert Enum.map(Users.list_user(), &Map.drop(&1, [:password])) == [Map.drop(user, [:password])]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Map.drop(Users.get_user!(user.id), [:password]) == Map.drop(user, [:password])
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "some username", email: "some@email", password: "somepassword"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.username == "some username"
      assert user.email == "some@email"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{username: "some updated username", email: "some@updatedemail"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.username == "some updated username"
      assert user.email == "some@updatedemail"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert Map.drop(user, [:password]) == Map.drop(Users.get_user!(user.id), [:password])
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
