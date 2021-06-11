defmodule MeetWeb.PageController do
  use MeetWeb, :controller

  def thank_you(conn, _) do
    conn
    |> put_layout("centered.html")
    |> render("thanks.html")
  end
end
