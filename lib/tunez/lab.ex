defmodule Tunez.Lab do
  @email "editor@mail.com"
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

  def create_artist() do
    fake_actor = %Tunez.Accounts.User{role: :editor}

    Tunez.Music.create_artist(
      %{
        name: "Test Artist without policy"
      },
      actor: fake_actor
    )

    "Artist created"
  end
end

# recompile; Tunez.Lab.register_user()

# recompile; Tunez.Lab.create_artist()
