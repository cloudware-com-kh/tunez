defmodule TunezWeb.Artists.ShowLive do
  use TunezWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Artist Profile")

    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    artist = %{
      id: "test-artist-1",
      name: "Artist Name",
      biography: "«some sample biography content»"
    }

    socket =
      socket
      |> assign(:artist, artist)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      Artist profile of {inspect(@artist)}
    </Layouts.app>
    """
  end

end
