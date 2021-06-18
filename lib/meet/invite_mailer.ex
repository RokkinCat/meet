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

    event = %ICalendar.Event{
      summary: subject,
      dtstart: start_at,
      dtend: end_at,
      description: agenda,
      uid: uuid,
      url: (if (include_video_link), do: Meet.link()),
      organizer: "mailto:#{Meet.email()}",
      attendees: Enum.map([Meet.email(), to_email], fn(a) ->
        %{
          "CN" => a, 
          "RSVP" => "TRUE",
          "PARTSTAT" => "NEEDS-ACTION",
          "ROLE" => "REQ-PARTICIPANT",
          original_value: "mailto:#{a}\n",
        }
      end)
    }

    organizer_event = %ICalendar.Event{
      summary: subject,
      dtstart: start_at,
      dtend: end_at,
      description: agenda,
      uid: uuid,
      url: (if (include_video_link), do: Meet.link()),
      organizer: "mailto:noreply@rokkincat.com",
      attendees: Enum.map([Meet.email(), to_email], fn(a) ->
        %{
          "CN" => a, 
          "RSVP" => "TRUE",
          "PARTSTAT" => "NEEDS-ACTION",
          "ROLE" => "REQ-PARTICIPANT",
          original_value: "mailto:#{a}\n",
        }
      end)
    }




    ics = %ICalendar{events: [event]}
    |> ICalendar.to_ics(vendor: "RKKN Meet")
    |> String.split("\n")
    |> List.insert_at(4, "METHOD:REQUEST") # This is required for it to show up correctly in gcal
    |> Enum.join("\n")

    organizer_ics = %ICalendar{events: [organizer_event]}
    |> ICalendar.to_ics(vendor: "RKKN Meet")
    |> String.split("\n")
    |> List.insert_at(4, "METHOD:REQUEST") # This is required for it to show up correctly in gcal
    |> Enum.join("\n")


    new() 
    |> to(Meet.email())
    |> from(Meet.email())
    |> reply_to(to_email)
    |> subject("Meeting with #{to_email}: #{subject}")
    |> html_body("<p>You're all set to have a meeting with nick gartmann</p>")
    |> attachment(Swoosh.Attachment.new({:data, organizer_ics}, filename: "invite.ics", headers: [{"Content-Type", "text/calendar; method=\"REQUEST\""}], content_type: "text/calendar; method=\"REQUEST\""))
    |> Meet.Mailer.deliver
  
    new() 
    |> to(to_email)
    |> from(Meet.email())
    |> reply_to(Meet.email())
    |> subject("Meeting with Nick Gartmann: #{subject}")
    |> html_body("<p>You're all set to have a meeting with nick gartmann</p>")
    |> attachment(Swoosh.Attachment.new({:data, ics}, filename: "invite.ics", headers: [{"Content-Type", "text/calendar; method=\"REQUEST\""}], content_type: "text/calendar; method=\"REQUEST\""))
    |> Meet.Mailer.deliver

  end

end
