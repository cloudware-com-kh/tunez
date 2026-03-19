defmodule Tunez.Lab do
  @email "admin@example.com"
  @album_id "1ff34fd0-2e6d-4c43-9489-43f470817985"

  def stream() do
    # RAM consumption
    1..100_000
    |> Enum.map(&(&1 * 3))
    |> Enum.filter(&odd?/1)
    # RAM consumption
    |> Enum.sum()
    |> IO.inspect()

    # No RAM consumption
    1..100_000
    |> Stream.map(&(&1 * 3))
    |> Stream.filter(&odd?/1)
    # No RAM consumption
    |> Enum.sum()
  end

  defp odd?(n), do: rem(n, 2) == 1

  def stream_album() do
    Tunez.Music.stream_album!(authorize?: false, stream?: true)
    |> Ash.bulk_update!(:bulk_update, %{},
      authorize?: false,
      resource: Tunez.Music.Album,
      domain: Tunez.Music
    )
  end
end

# recompile; Tunez.Lab.stream()
# recompile; Tunez.Lab.stream_album()
