defmodule Meet.InviteMailer do

  def send_meeting_invite(to, at, subject, agenda, include_video_link \\ true) do

    {:ok, start_at} = Timex.format(at, "{ISO:Basic:Z}")
    {:ok, end_at} = at
             |> Timex.shift(minutes: Meet.meeting_length())
             |> Timex.format("{ISO:Basic:Z}")

    event = %ICalendar.Event{
      summary: subject,
      dtstart: start_at,
      dtend: end_at,
      description: agenda,
      url: (if (include_video_link), do: Meet.link()),
      organizer: to,
      attendees: Enum.map([to, Meet.email()], fn(a) ->
        %{"CN" => a, original_value: a}
      end)
    }

    %ICalendar{events: [event]}
    |> ICalendar.to_ics(vendor: "RKKN Meet")
    |> IO.puts

  end

end
