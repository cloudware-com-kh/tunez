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
    actor = Tunez.Accounts.get_user_by_email!(@email, authorize?: false)
    # Manual assign user_id to the artist
    Tunez.Music.create_artist(
      %{
        name: "Artist created by editor auto assign user_id without related"
      },
      actor: actor
    )
  end

  def use_can?() do
    fake_actor = %Tunez.Accounts.User{role: :user}
    Tunez.Music.can_create_artist?(fake_actor)
  end
end

# recompile; Tunez.Lab.register_user()
# recompile; Tunez.Lab.use_can?()
# recompile; Tunez.Lab.create_artist()
