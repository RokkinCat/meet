defmodule Meet.Calendar do

  @ets_tablename :calendar
  @cache_age 5

  def all() do
    if should_refresh?() do
      fetch_all()
    else
      fetch_from_ets()
    end
  end

  def fetch_all() do
    Application.get_env(:meet, :urls) 
    |> Enum.map(&fetch_url/1)
    |> Enum.flat_map(&parse_ics/1)
    |> extend_recurrences()
    |> cache()
  end

  defp should_refresh?() do
    case :ets.lookup(@ets_tablename, :cache_key) do
      [] -> 
        true
      [cache_key: key] -> 
        Timex.diff(Timex.now(), key, :minutes) > @cache_age
    end
  end

  defp fetch_from_ets() do
    [calendars: cals] = :ets.lookup(@ets_tablename, :calendars)
    cals
  end

  defp cache(cals) do
    :ets.insert(@ets_tablename, {:calendars, cals})
    :ets.insert(@ets_tablename, {:cache_key, Timex.now()})
    cals
  end

  def fetch_url(url) do
    {:ok, %{body: body}} = Finch.build(:get, url)
                           |> Finch.request(Finch.Meet)
    body
  end

  def parse_ics(raw) do
    ICalendar.from_ics(raw)
  end

  def extend_recurrences(ics) do
    today = Timex.today()
    ics
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
    |> Enum.sort(fn(a,b) -> Timex.before?(b.dtstart, a.dtstart) end)
  end

end

