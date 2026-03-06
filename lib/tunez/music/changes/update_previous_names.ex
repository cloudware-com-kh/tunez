defmodule Tunez.Music.Changes.UpdatePreviousNames do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    changeset =
      Ash.Changeset.before_action(changeset, fn changeset ->
        IO.puts("\nBefore action call change body running==================")
        changeset
      end)

    changeset =
      Ash.Changeset.after_action(changeset, fn _changeset, saved_record ->
        IO.puts("\nAfter action call change body running==================")
        {:ok, saved_record}
      end)

    IO.puts("\nMain change body running==================")
    new_name = Ash.Changeset.get_attribute(changeset, :name)
    old_name = Ash.Changeset.get_data(changeset, :name)
    previous_names = Ash.Changeset.get_data(changeset, :previous_names)

    names =
      [old_name | previous_names]
      |> Enum.uniq()
      |> Enum.reject(&(&1 == new_name))

    if String.contains?(new_name, "fuck") do
      Ash.Changeset.add_error(changeset, field: :name, message: "No sexual word")
    else
      changeset
      |> Ash.Changeset.change_attribute(:previous_names, names)
    end
  end
end
