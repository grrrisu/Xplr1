defmodule Xplr1.OpenaiClient do
  alias Xplr1.Client

  @api_url "https://api.openai.com/v1/chat/completions"
  # gpt-4, gpt-4.1-nano
  @model "gpt-4.1-nano"

  def call_api(message, choices \\ 1) do
    config = Application.get_env(:xplr1, :openai_client)
    Client.mock_request(Xplr1.OpenaiClient, "test/fixtures/openai_response.json")

    [
      headers: headers(config[:api_key]),
      json: body(message, choices),
      url: @api_url,
      plug: config[:plug]
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
      model: @model,
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
