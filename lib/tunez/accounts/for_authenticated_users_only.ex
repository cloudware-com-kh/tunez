defmodule Tunez.Accounts.ForAuthenticatedUsersOnly do
  use TunezWeb, :live_view
  on_mount {TunezWeb.LiveUserAuth, :live_user_required}
end
