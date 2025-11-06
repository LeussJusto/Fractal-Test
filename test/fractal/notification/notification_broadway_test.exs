defmodule Fractal.Notifications.Broadcasters.NotificationBroadwayTest do
  use Fractal.DataCase, async: true
  import Phoenix.ChannelTest

  alias Fractal.Notifications.Publishers.NotificationPublisher
  @endpoint FractalWeb.Endpoint

  setup do
    :ok =
      case :brod.start_link_client([{~c"redpanda", 9092}], :kafka_client, []) do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end

    # Inicia el producer para el topic
    :ok = :brod.start_producer(:kafka_client, "notifications", [])

    # Inicia el Broadway consumer
    start_supervised!(Fractal.Notifications.Broadcasters.NotificationBroadway)

    :ok
  end

  describe "notificaciones por Kafka y Channel" do
    test "transmite evento de inscripción por Phoenix Channel" do
      user_id = "user123"
      course_id = "course456"

      {:ok, _, _socket} =
        subscribe_and_join(
          socket(@endpoint),
          FractalWeb.NotificationChannel,
          "notifications:" <> user_id
        )

      event = %{
        "type" => "enrollment_created",
        "user_id" => user_id,
        "course_id" => course_id,
        "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601()
      }

      :ok = NotificationPublisher.publish(event)

      assert_broadcast "new_notification", ^event, 5000
    end
  end
end
