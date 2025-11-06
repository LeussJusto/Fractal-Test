defmodule FractalWeb.NotificationChannel do
  use Phoenix.Channel

  @moduledoc """
  Canal Phoenix para notificaciones en tiempo real.
  """

  def join("notifications:" <> _user_id, _params, socket) do
    {:ok, socket}
  end
end
