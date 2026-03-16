defmodule Tunez.Lab do
  def run() do
    # %Tunez.Music.Artist{name: "Hi"}
    # |> Ash.load!(:name_length)

    # Ash.calculate(Tunez.Music.Artist, :name_length, refs: %{name: "Hi"})
    Tunez.Music.artist_name_length("Hi")
  end
end

# recompile; Tunez.Lab.run()
