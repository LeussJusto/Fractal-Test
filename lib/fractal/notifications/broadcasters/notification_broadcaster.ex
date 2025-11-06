defmodule Fractal.Notifications.Broadcasters.NotificationBroadway do
  @moduledoc """
  Broadcaster para notificaciones usando Broadway y BroadwayKafka.
  Consume eventos desde Redpanda/Kafka y los transmite por Phoenix Channel a los usuarios.
  """

  use Broadway

  alias Broadway.Message

  @topic "notifications"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          BroadwayKafka.Producer,
          [
            hosts: "redpanda:9092",
            group_id: "notification_broadway_group",
            topics: [@topic],
            client_id: "notification_broadway_client"
          ]
        },
        concurrency: 1
      ],
      processors: [default: [concurrency: 2]],
      batchers: [default: [concurrency: 2]]
    )
  end

  @impl true
  def handle_message(_processor, %Message{data: data} = msg, _context) do
    case Jason.decode(data) do
      {:ok, event} ->
        FractalWeb.Endpoint.broadcast(
          "notifications:#{event["user_id"]}",
          "new_notification",
          event
        )

        Message.put_batcher(msg, :default)

      {:error, reason} ->
        IO.puts("[NotificationBroadway] Error al decodificar evento: #{inspect(reason)}")
        msg
    end
  end

  @impl true
  def handle_batch(:default, messages, _batcher_context, _opts) do
    messages
  end
end
