defmodule HdfsClient do
  def open(host, port \\ 14000, scheme \\ :http, user \\ "hadoop") do
    with {:ok, conn} <- Mint.HTTP.connect(scheme, host, port) do
      {:ok, %{conn: conn, attrs: [{"user.name", user}]}}
    end
  end

  def close(state) do
    Mint.HTTP.close(state.conn)
    :ok
  end

  def list(state, path) do
    url = url(state, path, "LISTSTATUS", [])

    with {:ok, conn, _request_ref} <- Mint.HTTP.request(state.conn, "GET", url, [], nil) do
      {:ok, conn, 200, body} = get_response(conn)

      list =
        Jason.decode!(body)
        |> Map.get("FileStatuses")
        |> Map.get("FileStatus")

      {:ok, %{state | conn: conn}, list}
    end
  end

  def info(state, filename) do
    url = url(state, filename, "GETFILESTATUS", [])

    with {:ok, conn, _request_ref} = Mint.HTTP.request(state.conn, "GET", url, [], nil) do
      {:ok, conn, 200, body} = get_response(conn)

      info =
        Jason.decode!(body)
        |> Map.get("FileStatus")

      {:ok, %{state | conn: conn}, info}
    end
  end

  def read_all(state, filename) do
    url = url(state, filename, "OPEN", [])

    {:ok, conn, _request_ref} = Mint.HTTP.request(state.conn, "GET", url, [], nil)
    {:ok, conn, 200, body} = get_response(conn)
    {:ok, %{state | conn: conn}, body}
  end

  defp url(state, filename, operation, attrs) do
    filename = String.trim(filename, "/")
    query = URI.encode_query(state.attrs ++ [{"op", operation} | attrs])
    "/webhdfs/v1/#{filename}?#{query}"
  end

  defp get_response(conn) do
    {conn, response} = recv_all(conn)
    {:status, _, code} = :lists.keyfind(:status, 1, response)

    data =
      response
      |> Enum.filter(fn e -> :data == :erlang.element(1, e) end)
      |> Enum.map(&:erlang.element(3, &1))

    {:ok, conn, code, data}
  end

  defp recv_all(conn, data \\ []) do
    receive do
      {:tcp, _, _} = message ->
        {:ok, conn, mint_responses} = Mint.HTTP.stream(conn, message)

        case :lists.keyfind(:done, 1, mint_responses) do
          false ->
            recv_all(conn, [mint_responses | data])

          _ ->
            data =
              [mint_responses | data]
              |> Enum.reverse()
              |> List.flatten()

            {conn, data}
        end
    end
  end
end
