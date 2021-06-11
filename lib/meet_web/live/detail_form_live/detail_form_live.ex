defmodule MeetWeb.DetailFormLive do
  use MeetWeb, :live_view

  def expected_date_format(), do: "{YYYY}-{0M}-{0D}"
  def expected_time_format(), do: "{h24}:{m}"

  @impl true 
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"date" => date, "time" => time}, _, socket) do
    case Timex.parse("#{date} #{time}", "#{expected_date_format()} #{expected_time_format()}") do
      {:error, _} -> 
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, MeetWeb.TimeSelectLive, date))}
      {:ok, datetime} ->
        {:noreply, assign(socket, datetime: datetime)}
    end
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("send", params, socket) do
    %{
      "meeting" => %{
        "email" => email,
        "subject" => subject,
        "agenda" => agenda,
        "include_video_link" => include_video_link
      }
    } = params

    Meet.InviteMailer.send_meeting_invite(
      email, 
      socket.assigns[:datetime], 
      subject, 
      agenda, 
      include_video_link
    )

    {:noreply, push_redirect(socket, to: Routes.page_path(socket, :thank_you))}
  end

end
