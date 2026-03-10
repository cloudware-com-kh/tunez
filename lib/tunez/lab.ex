defmodule Tunez.Lab do
  @email "test@test.com"
  @password "password"
  def get_artist_id() do
    # Tunez.Music.read_artists!(page: [limit: 1], load: [albums: [:string_years_ago]])
    Tunez.Music.read_artists!(
      page: [limit: 2],
      load: [:album_count, :latest_album_year_released, :cover_image_url]
    )
    |> Map.get(:results)
  end

  def run() do
    get_artist_id()
  end

  def register_user() do
    Tunez.Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: @email,
      password: @password,
      password_confirmation: @password
    })
    |> Ash.create!(authorize?: false)
  end

  def sign_in_user() do
    signed_in_user =
      Tunez.Accounts.User
      |> Ash.Query.for_read(:sign_in_with_password, %{
        email: @email,
        password: @password
      })
      |> Ash.read_one!(authorize?: false)
      |> IO.inspect()

    access_token = signed_in_user.__metadata__.token
    AshAuthentication.Jwt.verify(access_token, :tunez)
  end

  def verify_client_access_token() do
    client_access_token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ-PiA0LjEzIiwiZXhwIjoxNzc0MzQxNzU5LCJpYXQiOjE3NzMxMzIxNTksImlzcyI6IkFzaEF1dGhlbnRpY2F0aW9uIHY0LjEzLjciLCJqdGkiOiIzMmRtc2pmcjM3ZW43bGVjNTQwMDAxdTIiLCJuYmYiOjE3NzMxMzIxNTksInB1cnBvc2UiOiJ1c2VyIiwic3ViIjoidXNlcj9pZD01YzgyODY0OS1jNjdjLTQyY2ItYTQwMi05ZjBmYjA3YzMwM2IifQ.3x_3_84dOh_t1beREU4mO9a0l25kV8pm1_g2C5fr7ls"

    {:ok, %{"sub" => subject}, resource} =
      AshAuthentication.Jwt.verify(client_access_token, :tunez)

    AshAuthentication.subject_to_user(subject, resource)
  end
end

# recompile; Tunez.Lab.register_user()
# recompile; Tunez.Lab.sign_in_user()
# recompile; Tunez.Lab.verify_client_access_token()
