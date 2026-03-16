defmodule Tunez.Music.Calculations.SecondsToMinutes do
  use Ash.Resource.Calculation
  # Slow way (work in loaded data layer)
  # def calculate(tracks, _opts, _context) do
  #   Enum.map(tracks, fn %{duration_seconds: seconds} ->
  #     minutes = div(seconds, 60)

  #     seconds =
  #       rem(seconds, 60)
  #       |> Integer.to_string()
  #       |> String.pad_leading(2, "0")

  #     "#{minutes}:#{seconds}"
  #   end)
  # end

  # Fast way with expression (work in data layer)
  def expression(_opts, _context) do
    expr(
      fragment("? / 60 || to_char(? * interval '1s', ':SS')", duration_seconds, duration_seconds)
    )
  end
end
