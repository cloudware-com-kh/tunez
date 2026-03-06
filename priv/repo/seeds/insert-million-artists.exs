# Seed data for 1,000,000 artists using faker library.
Faker.Lorem.sentences(1_000_000)
|> Enum.map(fn word -> %{name: word} end)
|> Ash.bulk_create!(Tunez.Music.Artist, :create, return_errors?: true, authorize?: false)
