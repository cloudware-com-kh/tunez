defmodule Tunez.Lab do
  def run() do
    form = Tunez.Music.form_to_create_artist()
    params = %{name: "Samnag via code_interface form extension", biography: "This is Samnang bio"}
    validated = AshPhoenix.Form.validate(form, params)
    AshPhoenix.Form.submit(validated, params: params)
  end
end
