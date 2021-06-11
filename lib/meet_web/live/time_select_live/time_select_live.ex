defmodule MeetWeb.TimeSelectLive do
  use MeetWeb, :live_view

  alias Meet.Availability

  @impl true
  def mount(params, _session, socket) do
    today = date_from_params(params)

    {:ok, raw} = File.read("./nick_at_rokkincat.ics")

    events = ICalendar.from_ics(raw)
             |> Enum.flat_map(fn(event) ->
               # Right now this handles recurring events by extrapolating their recur rule one year into
               # the future and then merging them into the whole list
               recurrences = ICalendar.Recurrence.get_recurrences(event, Timex.shift(today, years: 1))
               |> Enum.to_list()
               case Enum.at(recurrences, 0) do
                 [] -> [event]
                 _ -> Enum.concat([event], recurrences)
               end
             end)
             |> Enum.filter(fn(event) -> !is_past?(event.dtstart) end) # This probably breaks for multi-day events
             |> Enum.sort(fn(a,b) -> Timex.diff(today, b.dtstart) > Timex.diff(today, a.dtstart) end)

    weekdays = build_week(today, events)

    {:ok, assign(socket, today: today, weekdays: weekdays, events: events, selected: nil)}
  end

  @impl true
  def handle_params(params, _, socket) do
    today = date_from_params(params)
    weekdays = build_week(today, socket.assigns.events)

    if all_weekdays_are_past(weekdays) do
      today = Timex.now(Meet.timezone())
              |> Timex.format!("{YYYY}-{0M}-{0D}")
      {:noreply, push_patch(socket, to: "/#{today}")}
    else
      {:noreply, assign(socket, today: today, weekdays: weekdays, selected: nil)}
    end
  end

  @impl true
  def handle_event("inc_week", _, socket) do
    today = Timex.shift(socket.assigns.today, weeks: 1)
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  @impl true
  def handle_event("dec_week", _, socket) do
    today = Timex.shift(socket.assigns.today, weeks: -1)
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  @impl true
  def handle_event("set_today", _, socket) do
    today = Timex.today(Meet.timezone())
            |> Timex.format!("{YYYY}-{0M}-{0D}")
    {:noreply, push_patch(socket, to: "/#{today}")}
  end

  @impl true
  def handle_event("select_time", %{"time" => timestamp}, socket) do
    selected = Timex.parse!(timestamp, "{ISO:Extended:Z}")
               |> Timex.to_datetime(Meet.timezone())
    {:noreply, assign(socket, selected: selected)}
  end

  @impl true
  def handle_event("schedule", _, socket) do
    date = Timex.format!(socket.assigns.selected, MeetWeb.DetailFormLive.expected_date_format())
    time = Timex.format!(socket.assigns.selected, MeetWeb.DetailFormLive.expected_time_format())
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MeetWeb.DetailFormLive, date, time))}
  end

  defp weekdays(day) do
    beginning = Timex.beginning_of_week(day, :mon)
    ending    = Timex.end_of_week(day, :sat)
    Timex.Interval.new(from: beginning, until: ending, right_open: false, step: [days: 1])
  end

  def is_today?(day) do
    Timex.diff(Timex.today(Meet.timezone()), day, :days) == 0
  end

  def is_past?(day) do
    Timex.diff(day, Timex.now(Meet.timezone()), :days) < 0  
  end

  def is_selected?(nil, _), do: false
  def is_selected?(ref, target) do
    Timex.diff(ref, target, :minutes) == 0
  end

  def week_contains_today(week) do
    today = Timex.now(Meet.timezone())
    Enum.find(week, fn({d,_}) -> Timex.diff(d, today, :days) == 0 end) != nil
  end

  def all_weekdays_are_past(week) do
    Enum.all?(week, fn({d,_}) -> is_past?(d) end)
  end

  def date_from_params(%{"date" => date}) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date
      _ -> date_from_params(nil)
    end
  end
  def date_from_params(_), do: Timex.now(Meet.timezone())

  defp build_week(day, events) do
    weekdays(day)
    |> Enum.map(fn(d) -> 
      {d, Availability.available_times_on(events, d)}
    end)
    |> Enum.sort(fn({d1,_}, {d2, _}) ->
      Timex.diff(d1, d2) <= 0
    end)
  end

end
