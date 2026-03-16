defmodule Tunez.Lab do
  import Tunez.Generator

  def run() do
    generate(
      user(
        role: :admin,
        email: "admin@example.com"
      )
    )

    generate(user(role: :editor, email: "editor@example.com"))
  end

  def create_album() do
    actor = generate(user(role: :editor))
    artist = generate(artist())

    Tunez.Music.create_album!(%{name: "New Album", year_released: 2024, artist_id: artist.id},
      actor: actor
    )
  end
end

# recompile; Tunez.Lab.run()
# recompile; Tunez.Lab.create_album()
