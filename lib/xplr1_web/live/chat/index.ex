defmodule Xplr1Web.Chat.Index do
  use Xplr1Web, :live_view

  # alias Xplr1.OpenaiClient, as: ChatClient
  alias Xplr1.AnthropicClient, as: ChatClient

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_form() |> assign(context: nil, answers: [], thinking: false)}
  end

  defp assign_form(socket, prompt \\ nil) do
    assign(socket, form: to_form(%{"prompt" => prompt}))
  end

  @impl true
  def handle_event("change", %{"prompt" => prompt}, socket) do
    {:noreply, assign_form(socket, prompt)}
  end

  @impl true
  def handle_event("send", %{"prompt" => prompt}, socket) do
    {:noreply,
     assign_form(socket)
     |> assign(thinking: true)
     |> assign(:answers, [{:user, prompt} | socket.assigns.answers])
     |> start_async(:question, fn -> ChatClient.call_api(prompt) end)}
  end

  @impl true
  def handle_async(:question, {:ok, {:ok, answer}}, socket) do
    {:noreply,
     assign(socket, thinking: false, answers: [{:assistant, answer} | socket.assigns.answers])}
  end

  @impl true
  def handle_async(:question, {:exit, reason}, socket) do
    {:noreply, put_flash(socket, :error, Exception.format(:exit, reason))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <h1 class="text-lg font-bold">Chat</h1>
      <.context text={@context} />
      <.form for={@form} phx-change="change" phx-submit="send">
        <.input label="Prompt" field={@form["prompt"]} />
      </.form>
      <.conversation answers={@answers} thinking={@thinking} />
    </Layouts.app>
    """
  end

  def context(assigns) do
    ~H"""
    <div tabindex="0" class="collapse collapse-arrow bg-base-100 border-base-300 border">
      <div class="collapse-title font-semibold">Context</div>
      <div class="collapse-content text-xs">
        <pre class="whitespace-pre-line">{@text}</pre>
      </div>
    </div>
    """
  end

  def conversation(assigns) do
    ~H"""
    <div :if={@thinking} class="text-right">
      <progress class="progress progress-primary w-56"></progress> Thinking...
    </div>
    <div :for={{author, text} <- @answers}>
      <div class={"chat #{chat_align(author)}"}>
        <div class={"chat-bubble #{chat_color(author)}"}>
          <pre class="whitespace-pre-line">{text}</pre>
        </div>
      </div>
    </div>
    """
  end

  defp chat_align(:user), do: "chat-start"
  defp chat_align(:assistant), do: "chat-end"

  defp chat_color(:user), do: "chat-bubble-secondary"
  defp chat_color(:assistant), do: "chat-bubble-primary"
end
