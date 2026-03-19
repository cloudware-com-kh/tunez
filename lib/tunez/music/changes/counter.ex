defmodule Tunez.Music.Changes.Counter do
  use Ash.Resource.Change

  def atomic(_changeset, opts, _context) do
    if opts[:increase] do
      {:atomic, %{counter: expr(counter + 1)}}
    else
      {:atomic, %{counter: expr(counter - 1)}}
    end
  end
end
