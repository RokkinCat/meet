defmodule Meet.Availability do

  # schedule is a list of ICalendar.Event structs
  def available_at?(schedule, datetime, offset_minutes \\ [-30, 30], timezone \\ "America/Chicago")
  def available_at?(schedule, datetime, offset_minutes, timezone) do
    filtered_to_day = Enum.filter(schedule, fn(event) ->
      event.dtend != nil &&
      Timex.diff(event.dtstart, datetime, :days) == 0
    end)

    if Timex.diff(datetime, Timex.now(timezone)) < 0 do
      false
    else
      !Enum.any?(filtered_to_day, &(datetime_is_during_event?(&1, datetime, offset_minutes)))
    end
  end

  def datetime_is_during_event?(event, datetime, offset_minutes \\ [0, 0])
  def datetime_is_during_event?(event, datetime, [padding_before, padding_after]) do
    Timex.diff(Timex.shift(event.dtstart, minutes: padding_before), datetime) <= 0 &&
    Timex.diff(Timex.shift(event.dtend, minutes: padding_after), datetime) >= 0
  end

  # schedule is a list of ICalendar.Event structs
  def available_times_on(schedule, date, working_hours \\ [9,16], timezone \\ "America/Chicago")
  def available_times_on(schedule, date, [day_starts_at_hour, day_ends_at_hour], timezone) do
    beginning_of_day = Timex.set(date, hour: day_starts_at_hour, minute: 0, second: 0)
    end_of_day = Timex.set(date, hour: day_ends_at_hour, minute: 0, second: 0)
    Timex.Interval.new(from: beginning_of_day, until: end_of_day, right_open: false, step: [minutes: 30])
    |> Enum.map(fn(dt) -> Timex.to_datetime(dt, timezone) end)
    |> Enum.filter(&(available_at?(schedule, &1)))
  end

end
