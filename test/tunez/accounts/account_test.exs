defmodule Tunez.Accounts.AccountTest do
  use Tunez.DataCase, async: true
  alias Tunez.Accounts, warn: false
  import Tunez.Generator

  describe "policies" do
    test "users can only read themselves" do
      [actor, other] = generate_many(user(), 2)
      assert Accounts.can_get_user_by_email?(actor, actor.email, data: actor)
      refute Accounts.can_get_user_by_email?(actor, other.email, data: other)
    end

    test "admins can read all users" do
      [user1, user2] = generate_many(user(), 2)
      admin = generate(user(role: :admin))
      assert Accounts.can_get_user_by_email?(admin, user1.email, data: user1)
      assert Accounts.can_get_user_by_email?(admin, user2.email, data: user2)
    end
  end
end
