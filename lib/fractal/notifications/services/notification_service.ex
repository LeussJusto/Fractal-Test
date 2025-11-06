defmodule Fractal.Notifications.Services.NotificationService do
  @moduledoc """
  Lógica de negocio para notificaciones.
  """
  alias Fractal.Notifications.Publishers.NotificationPublisher

  def notify_enrollment_created(user_id, course_id) do
    event = %{
      type: :enrollment_created,
      user_id: user_id,
      course_id: course_id,
      timestamp: DateTime.utc_now()
    }

    NotificationPublisher.publish(event)
  end

  def notify_enrollment_cancelled(user_id, course_id) do
    event = %{
      type: :enrollment_cancelled,
      user_id: user_id,
      course_id: course_id,
      timestamp: DateTime.utc_now()
    }

    NotificationPublisher.publish(event)
  end
end
