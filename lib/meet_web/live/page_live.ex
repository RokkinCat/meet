defmodule MeetWeb.PageLive do
  use MeetWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    today = case params["date"] do
      nil -> Timex.now("America/Chicago")
      date -> Timex.parse!(date, "{YYYY}-{0M}-{0D}")
    end

    {:ok, raw} = File.read("./nick_at_rokkincat.ics")

    events = ICalendar.from_ics(raw)
             |> Enum.flat_map(fn(event) ->
               recurrences = ICalendar.Recurrence.get_recurrences(event, Timex.shift(today, years: 1))
               |> Enum.to_list()
               case Enum.at(recurrences, 0) do
                 [] -> [event]
                 _ -> Enum.concat([event], recurrences)
               end
             end)
             |> Enum.sort(fn(a,b) -> Timex.diff(today, b.dtstart) > Timex.diff(today, a.dtstart) end)

    weekdays = build_week(today, events)

    {:ok, assign(socket, today: today, weekdays: weekdays, events: events, selected: nil)}
  end

  def handle_params(%{"date" => date}, _, socket) do
    today = case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, pdate} -> pdate
      _ -> Timex.now("America/Chicago")
    end
    weekdays = build_week(today, socket.assigns.events)
    {:noreply, assign(socket, today: today, weekdays: weekdays, selected: nil)}
  end

  def handle_event("inc_week", _, socket) do
    today = Timex.shift(socket.assigns.today, weeks: 1)
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  def handle_event("dec_week", _, socket) do
    today = Timex.shift(socket.assigns.today, weeks: -1)
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  def handle_event("set_today", _, socket) do
    today = Timex.today("America/Chicago")
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  def handle_event("select_time", %{"time" => timestamp}, socket) do
    selected = Timex.parse!(timestamp, "{ISO:Extended:Z}")
               |> Timex.to_datetime("America/Chicago")
    {:noreply, assign(socket, selected: selected)}
  end

  def handle_event("schedule", _, socket) do
    IO.inspect "DOING IT, #{socket.assigns[:selected]}"
    {:noreply, socket}
  end

  defp weekdays(day) do
    beginning = Timex.beginning_of_week(day, :mon)
    ending    = Timex.end_of_week(day, :sat)
    Timex.Interval.new(from: beginning, until: ending, right_open: false, step: [days: 1])
  end

  def available_times_on(schedule, day) do
    beginning = Timex.set(day, hour: 9, minute: 0, second: 0)
    ending    = Timex.set(day, hour: 16, minute: 0, second: 0)
    Timex.Interval.new(from: beginning, until: ending, right_open: false, step: [minutes: 30])
    |> Enum.map(fn(dt) -> Timex.to_datetime(dt, "America/Chicago") end)
    |> Enum.filter(&(available?(schedule, &1)))
  end

  defp available?(schedule, datetime) do
    filtered = Enum.filter(schedule, &(&1.dtend != nil))
               |> Enum.filter(fn(event) -> 
                 Timex.diff(event.dtstart, datetime, :days) == 0
               end)

    if Timex.diff(datetime, Timex.now("America/Chicago")) < 0  do
      # If in the past, can't schedule for this time
      false 
    else
      !Enum.any?(filtered, fn(event) -> 
        datetime_during_event?(event, datetime)     
      end)
    end
  end

  def datetime_during_event?(event, datetime) do
    Timex.diff(Timex.shift(event.dtstart, minutes: -30), datetime) <= 0 && 
    Timex.diff(Timex.shift(event.dtend, minutes: 30), datetime) >= 0
  end

  def is_today?(day) do
    Timex.diff(Timex.today("America/Chicago"), day, :days) == 0
  end

  def is_past?(day) do
    Timex.diff(day, Timex.now("America/Chicago"), :days) < 0  
  end

  def is_selected?(nil, _), do: false
  def is_selected?(ref, target) do
    Timex.diff(ref, target, :minutes) == 0
  end

  defp build_week(day, events) do
    weekdays(day)
    |> Enum.map(fn(d) -> 
      {d, available_times_on(events, d)}
    end)
    |> Enum.sort(fn({d1,_}, {d2, _}) ->
      Timex.diff(d1, d2) <= 0
    end)
  end

end
