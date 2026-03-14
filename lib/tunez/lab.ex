defmodule Tunez.Lab do
  @email "admin@mail.com"
  @password "password"

  def register_user() do
    user =
      Tunez.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: @email,
        password: @password,
        password_confirmation: @password
      })
      |> Ash.create!()

    Tunez.Accounts.set_user_role(user.id, :editor, authorize?: false)
  end
end
