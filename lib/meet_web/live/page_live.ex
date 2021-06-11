defmodule MeetWeb.PageLive do
  use MeetWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok, socket}
  end

end
