defmodule TunezWeb.PageController do
  use TunezWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
