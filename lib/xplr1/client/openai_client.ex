defmodule Xplr1.OpenaiClient do
  @api_url "https://api.openai.com/v1/chat/completions"

  def call_api(message, choices \\ 1) do
    {:ok, api_key} = System.fetch_env("OPENAI_API_KEY")

    Req.Test.stub(Xplr1.OpenaiClient, fn conn ->
      {:ok, content} = File.read("test/fixtures/openai_response.json")
      {:ok, json} = Jason.decode(content)
      Req.Test.json(conn, json)
    end)

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    body = %{
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

    plug = Application.get_env(:xplr1, :openai_client, plug: nil) |> Keyword.get(:plug)

    case Req.post(@api_url, json: body, headers: headers, plug: plug) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, extract_content(response)}

      {:ok, %{status: status, body: body}} ->
        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
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
