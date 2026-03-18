defmodule Tunez.Lab do
  @email "admin@example.com"

  def bulk_action() do
    actor = Tunez.Accounts.get_user_by_email!(@email, authorize?: false)

    artists = [
      %{name: "Artist #{Faker.Lorem.word()}"},
      %{name: "Artist #{Faker.Lorem.word()}"},
      %{name: "Artist #{Faker.Lorem.word()}"}
    ]

    Tunez.Music.create_artist!(artists,
      actor: actor
      # bulk_options: [
      #   return_records?: true
      # ]
    )
  end
end

# recompile; Tunez.Lab.bulk_action()
