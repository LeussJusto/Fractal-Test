defmodule FractalWeb.ErrorJSON do
  @moduledoc """
  Renderizador de errores para respuestas JSON.
  """

  # Renderiza error 404
  def render("404.json", _assigns) do
    %{error: %{message: "Not Found"}}
  end

  # Renderiza error 500
  def render("500.json", _assigns) do
    %{error: %{message: "Internal Server Error"}}
  end

  # Renderiza otros errores
  def render(template, _assigns) do
    %{error: %{message: Phoenix.Controller.status_message_from_template(template)}}
  end
end
