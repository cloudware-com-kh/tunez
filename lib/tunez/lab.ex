defmodule Tunez.Lab do
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
end

# recompile; Tunez.Lab.run()
