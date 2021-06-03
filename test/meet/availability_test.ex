defmodule Meet.AvailabilityTest do
  use ExUnit.Case

  @schedule ICalendar.from_ics(
"""
BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:-//Elixir ICalendar//RKKN Meet//EN
BEGIN:VEVENT
DTSTART:20210706T173000Z
DTEND:20210706T182000Z
UID:3qke9bactdnomd0vkiiqj3flsg@google.com
SUMMARY:BOOK CLUB
END:VEVENT
END:VCALENDAR
""")

  import Meet.Availability

  describe "available_at?/4" do

    test "available the day before " do
      assert available_at?(@schedule, ~N[2021-07-05 09:00:00])
    end

    test "available the day after " do
      assert available_at?(@schedule, ~N[2021-07-05 09:00:00])
    end

    test "available the same day, before the event" do
      assert available_at?(@schedule, ~N[2021-07-06 09:00:00])
    end

    test "available the same day, after the event" do
      assert available_at?(@schedule, ~N[2021-07-06 16:00:00])
    end

    test "not available at the start of the event" do
      assert not available_at?(@schedule, ~N[2021-07-06 17:30:00])
    end

    test "not available at the end of the event" do
      assert !available_at?(@schedule, ~N[2021-07-06 18:20:00])
    end

    test "not available during the event" do
      assert not available_at?(@schedule, ~N[2021-07-06 18:00:00])
    end

    test "not available in the offset minutes before the event" do
      assert not available_at?(@schedule, ~N[2021-07-06 17:15:00])
    end

    test "not available in the offset minutes after the event" do
      assert not available_at?(@schedule, ~N[2021-07-06 18:30:00])
    end

  end

  describe "available_times_on/4" do

    test "all times are available on a day with no events" do
      times = available_times_on(@schedule, ~N[2021-07-05 09:00:00])
      assert Enum.count(times) == 15
    end

    test "exclude times around event" do
      times = available_times_on(@schedule, ~N[2021-07-06 09:00:00])
      assert Enum.count(times) == 11
      assert Enum.find(times, fn(time) -> time.hour == 12 end) == nil
      assert Enum.find(times, fn(time) -> time.hour == 12 && time.minute == 30 end) == nil
      assert Enum.find(times, fn(time) -> time.hour == 13 end) == nil
      assert Enum.find(times, fn(time) -> time.hour == 13 && time.minute == 30 end) == nil
    end

  end

end
