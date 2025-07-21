defmodule Xplr1.Client do
  @doc """
  options: url, headers, body
  """
  def call_api(options, extract_func) do
    options
    |> Keyword.merge(method: :post, receive_timeout: 60_000)
    |> Req.request()
    |> handle_response(extract_func)
  end

  def mock_request(key, file) do
    Req.Test.stub(key, fn conn ->
      with {:ok, content} <- File.read(file),
           {:ok, json} <- Jason.decode(content) do
        Req.Test.json(conn, json)
      end
    end)
  end

  def get_api_key(env_var) do
    System.fetch_env!(env_var)
  end

  def get_plug(key) do
    Application.get_env(:xplr1, key, plug: nil) |> Keyword.get(:plug)
  end

  defp handle_response(response, extract_func) do
    case response do
      {:ok, %{status: 200, body: response}} ->
        {:ok, extract_func.(response)}

      {:ok, %{status: status, body: body}} ->
        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end
end
