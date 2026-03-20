import Tunez.Generator
require Ash.Query
# cleanup existing users
Tunez.Accounts.User
|> Ash.Query.filter(email in ["admin@example.com", "editor@example.com", "user@example.com"])
|> Tunez.Accounts.destroy_user(authorize?: false)

generate(user(role: :admin, email: "admin@example.com"))
generate(user(role: :editor, email: "editor@example.com"))
generate(user(role: :user, email: "user@example.com"))
