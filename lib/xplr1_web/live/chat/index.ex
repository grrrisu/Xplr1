defmodule Xplr1Web.Chat.Index do
  use Xplr1Web, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Chat")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <h1>{@page_title}</h1>
      <p>Welcome to the chat page!</p>
    </Layouts.app>
    """
  end
end
