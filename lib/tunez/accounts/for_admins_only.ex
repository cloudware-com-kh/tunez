defmodule Tunez.Accounts.ForAdminsOnly do
  use TunezWeb, :live_view
  on_mount {TunezWeb.LiveUserAuth, role_required: :admin}
end
