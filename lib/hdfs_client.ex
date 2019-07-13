defmodule HdfsClient do
  @moduledoc """
  Documentation for HdfsClient.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HdfsClient.hello()
      :world

  """
  def hello do
    :world
  end

  def init(url, user \\ "hadoop") do
    %{url: url, user: user, path: "", attrs: [{"user.name", user}]}
  end

  def cd(state, path) do
    %{state | path: :filename.join(state.path, path)}
  end

  def list(state) do
    url = url(state, "", "LISTSTATUS", [])

    with {:ok, '200', _, body} <- :ibrowse.send_req(url, [], :get, [], response_format: :binary),
         {:ok, list} <- Jason.decode(body) do
      list
      |> Map.get("FileStatuses")
      |> Map.get("FileStatus")
    end
  end

  def info(state, filename) do
    url = url(state, filename, "GETFILESTATUS", [])

    with {:ok, '200', _, body} <- :ibrowse.send_req(url, [], :get, [], response_format: :binary),
         {:ok, list} <- Jason.decode(body) do
      list
      |> Map.get("FileStatus")
    end
  end

  def read(state, filename) do
    url = url(state, filename, "OPEN", [])

    with {:ok, '200', _, body} <- :ibrowse.send_req(url, [], :get, [], response_format: :binary) do
      {:ok, body}
    end
  end

  defp strip(str) do
    String.trim(str, "/")
  end

  defp url(state, filename, operation, attrs) do
    path = :filename.join(state.path, filename)
    query = :uri_string.compose_query(state.attrs ++ [{"op", operation} | attrs])
    "#{strip(state.url)}/#{strip(path)}?#{query}" |> String.to_charlist()
  end
end
