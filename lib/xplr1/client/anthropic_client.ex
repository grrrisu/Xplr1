defmodule Xplr1.AnthropicClient do
  @api_url "https://api.anthropic.com/v1/messages"

  def call_api(message) do
    {:ok, api_key} = System.fetch_env("ANTHROPIC_API_KEY")

    Req.Test.stub(Xplr1.AnthropicClient, fn conn ->
      {:ok, content} = File.read("test/fixtures/anthropic_claude_sonnet_4_response.json")
      {:ok, json} = Jason.decode(content)
      Req.Test.json(conn, json)
    end)

    headers = [
      {"Content-Type", "application/json"},
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"}
    ]

    body = %{
      # claude-3-5-sonnet-20241022 or claude-sonnet-4-20250514
      model: "claude-3-5-sonnet-20241022",
      max_tokens: 1000,
      messages: [
        %{role: "user", content: message}
      ]
    }

    plug = Application.get_env(:xplr1, :anthropic_client, plug: nil) |> Keyword.get(:plug)

    case Req.post(@api_url, json: body, receive_timeout: 60_000, headers: headers, plug: plug) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, extract_content(response)}

      {:ok, %{status: status, body: body}} ->
        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
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
