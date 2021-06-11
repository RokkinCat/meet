defmodule Meet do
  @moduledoc """
  Meet keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  
  def timezone() do
    Application.get_env(:meet, :timezone)
  end

end
