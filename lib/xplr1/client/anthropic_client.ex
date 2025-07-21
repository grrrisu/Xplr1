defmodule Xplr1.AnthropicClient do
  alias Xplr1.Client

  @api_url "https://api.anthropic.com/v1/messages"
  # claude-3-5-sonnet-20241022 or claude-sonnet-4-20250514
  @model "claude-sonnet-4-20250514"

  def call_api(message) do
    config = Application.get_env(:xplr1, :anthropic_client)

    Client.mock_request(
      Xplr1.AnthropicClient,
      "test/fixtures/anthropic_claude_sonnet_4_response.json"
    )

    [
      headers: headers(config[:api_key]),
      json: body(message),
      url: @api_url,
      plug: config[:plug]
    ]
    |> Client.call_api(&extract_content/1)
  end

  def headers(api_key) do
    [
      {"Content-Type", "application/json"},
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"}
    ]
  end

  def body(message) do
    %{
      model: @model,
      max_tokens: 5000,
      messages: [
        %{role: "user", content: message}
      ]
    }
  end

  defp extract_content(%{"content" => content_blocks}) do
    case content_blocks do
      [] ->
        "No content available"

      [%{"text" => text}] ->
        text

      blocks when is_list(blocks) ->
        texts =
          Enum.map(content_blocks, fn
            %{"text" => text} -> text
            %{"type" => "text", "text" => text} -> text
            block -> "Non-text block: #{inspect(block)}"
          end)

        Enum.join(texts, "\n")
    end
  end

  defp extract_content(response) do
    "Unexpected response format: #{inspect(response)}"
  end
end
