defmodule Meet.Mailer do
  use Swoosh.Mailer, otp_app: :meet
end

defmodule Meet.InviteEmail do
  import Swoosh.Email

  def send_meeting_invites(to_email, at, subject, agenda, include_video_link \\ true) do

    {:ok, start_at} = Timex.format(at, "{ISO:Basic:Z}")
    {:ok, end_at} = at
             |> Timex.shift(minutes: Meet.meeting_length())
             |> Timex.format("{ISO:Basic:Z}")

    uuid = UUID.uuid4()

    send_host_invite(to_email, uuid, start_at, end_at, subject, agenda, include_video_link)
    send_requester_invite(to_email, uuid, start_at, end_at, subject, agenda, include_video_link)

  end


  defp send_host_invite(to, uid, start_at, end_at, subject, agenda, include_video_link) do
    event = build_event(
      uid,
      subject,
      agenda,
      start_at, 
      end_at,
      "noreply@rokkincat.com",
      [Meet.email(), to],
      (if (include_video_link), do: Meet.link())
    )
    ics = build_calendar([event])

    new() 
    |> to(Meet.email())
    |> from("noreply@rokkincat.com")
    |> reply_to(to)
    |> subject("Meeting with #{to}: #{subject}")
    |> html_body(EEx.eval_file("lib/meet/templates/host_email.html.eex", include_video_link: include_video_link, video_link: Meet.link()))
    |> attachment(build_ics_attachment(ics))
    |> Meet.Mailer.deliver

  end

  defp send_requester_invite(to, uid, start_at, end_at, subject, agenda, include_video_link) do
    event = build_event(
      uid,
      subject,
      agenda,
      start_at, 
      end_at,
      Meet.email(),
      [Meet.email(), to],
      (if (include_video_link), do: Meet.link())
    )
    ics = build_calendar([event])
    
    new() 
    |> to(to)
    |> from(Meet.email())
    |> reply_to(Meet.email())
    |> subject("Meeting with Nick Gartmann: #{event.summary}")
    |> html_body(EEx.eval_file("lib/meet/templates/requester_email.html.eex", include_video_link: include_video_link, video_link: Meet.link()))
    |> attachment(build_ics_attachment(ics))
    |> Meet.Mailer.deliver
  end

  defp build_event(uid, summary, description, dtstart, dtend, organizer, attendees, url) when is_list(attendees) do
    %ICalendar.Event{
      uid: uid,
      summary: summary,
      description: description,
      dtstart: dtstart,
      dtend: dtend,
      url: url,
      organizer: "mailto:#{organizer}",
      attendees: Enum.map(attendees, fn(attendee) -> 
        %{
          "CN" => attendee, # Attendee's display name, just using their email address
          "RSVP" => true,   # Tells the calendar app that the organizer is expecting a response
          "PARTSTAT" => "NEEDS-ACTION", # Tells the calendar app that the user hasn't responded yet
          "ROLE" => "REQ-PARTICIPANT", # If the user is required or optional
          original_value: "mailto:#{attendee}\n"
        }
      end)
    }
  end

  defp build_calendar(events) when is_list(events) do
    %ICalendar{events: events}
    |> ICalendar.to_ics(vendor: "RKKN Meet")
    |> String.split("\n")
    |> List.insert_at(4, "METHOD:REQUEST") # This is required for it to show up correctly in gcal
    |> Enum.join("\n")
  end

  defp build_ics_attachment(ics) do
    Swoosh.Attachment.new(
      {:data, ics}, 
      filename: "invite.ics", 
      headers: [{"Content-Type", "text/calendar; method=\"REQUEST\""}], # method value here must match the method value in the ics
      content_type: "text/calendar; method=\"REQUEST\""
    )
  end

end
