defmodule Tunez.Lab do
  import Tunez.Generator
  @email "admin@example.com"
  def create_admin() do
    generate(user(role: :admin, email: @email))
  end
end

# recompile; Tunez.Lab.create_admin()
