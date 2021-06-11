defmodule Meet.InviteMailer do

  def send_meeting_invite(to, at, subject, agenda, include_video_link \\ true) do
    """
    Sending invite to: #{to} and #{Meet.email()}
    Meeting at: #{at}

    #{subject}

    #{agenda}
    """
    |> IO.puts
  end

end
