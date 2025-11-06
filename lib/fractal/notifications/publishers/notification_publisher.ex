defmodule Fractal.Notifications.Publishers.NotificationPublisher do
  @moduledoc """
  Publisher para eventos de notificación.
  Envía mensajes a Redpanda/Kafka cuando ocurre una acción relevante (inscripción, cancelación, etc).

  """

  @topic "notifications"

  def publish(event) do
    # Convierte el evento a claves string para JSON
    event = for {k, v} <- event, into: %{}, do: {to_string(k), v}
    payload = Jason.encode!(event)
    key = event["user_id"]
    partition = 0

    case :brod.produce_sync(:kafka_client, @topic, partition, key, payload) do
      :ok ->
        IO.puts("[NotificationPublisher] Evento publicado en Kafka: #{inspect(event)}")
        :ok

      {:error, reason} ->
        IO.puts("[NotificationPublisher] Error al publicar en Kafka: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
