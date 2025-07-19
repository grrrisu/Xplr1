defmodule Xplr1.OpenaiClient do
  alias Xplr1.Client

  @api_url "https://api.openai.com/v1/chat/completions"

  def call_api(message, choices \\ 1) do
    api_key = Client.get_api_key("OPENAI_API_KEY")
    Client.mock_request(Xplr1.OpenaiClient, "test/fixtures/openai_response.json")

    [
      headers: headers(api_key),
      json: body(message, choices),
      url: @api_url,
      plug: Client.get_plug(:openai_client)
    ]
    |> Client.call_api(&extract_content/1)
  end

  def headers(api_key) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]
  end

  def body(message, choices) do
    %{
      model: "gpt-4.1-nano",
      messages: [
        %{role: "user", content: message}
      ],
      max_tokens: 1000,
      # Request multiple choices
      n: choices,
      # Higher temperature for more variety
      temperature: 0.9
    }
  end

  defp extract_content(%{"choices" => choices}) do
    case choices do
      [] ->
        "No content available"

      [%{"message" => %{"content" => content}}] ->
        content

      choices ->
        choices
        |> Enum.map(fn %{"message" => %{"content" => content}} -> content end)
        |> Enum.join("\n")
    end
  end

  defp extract_content(response) do
    "Unexpected response format: #{inspect(response)}"
  end
end
