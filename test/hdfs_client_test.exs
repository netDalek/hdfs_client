defmodule HdfsClientTest do
  use ExUnit.Case
  doctest HdfsClient

  test "greets the world" do
    assert 1 <
             HdfsClient.init("http://hdp-node1.staging.fun-box.ru:14000/webhdfs/v1/")
             |> HdfsClient.cd("/a2p")
             |> HdfsClient.list()
             |> Enum.map(&Map.get(&1, "pathSuffix"))
             |> Enum.join()
             |> String.length()
  end

  test "info" do
    assert %{"type" => "FILE"} =
             HdfsClient.init("http://hdp-node1.staging.fun-box.ru:14000/webhdfs/v1/")
             |> HdfsClient.cd("/a2p")
             |> HdfsClient.info("templates.json")
  end

  test "read" do
    assert {:ok, body} =
             HdfsClient.init("http://hdp-node1.staging.fun-box.ru:14000/webhdfs/v1/")
             |> HdfsClient.cd("/a2p")
             |> HdfsClient.read("templates.json")
  end

  defp recv_all(conn, data \\ []) do
    receive do
      {:tcp, _, _} = message ->
        {:ok, conn, mint_responses} = Mint.HTTP.stream(conn, message)

        case :lists.keyfind(:done, 1, mint_responses) do
          false ->
            recv_all(conn, [mint_responses | data])

          _ ->
            data = [mint_responses | data]
            |> Enum.reverse()
            |> List.flatten()

            {conn, data}
        end
    end
  end

  test "mint" do
    {:ok, conn} = Mint.HTTP.connect(:http, "hdp-node1.staging.fun-box.ru", 14000)

    {:ok, conn, _request_ref} =
      Mint.HTTP.request(conn, "GET", "/webhdfs/v1?user.name=hadoop&op=LISTSTATUS", [], nil)

    {:ok, conn, 200, body} = get_response(conn)
    %{"FileStatuses" => _} = body |> Jason.decode!()

    {:ok, conn, _request_ref} =
      Mint.HTTP.request(conn, "GET", "/webhdfs/v1?user.name=hadoop&op=LISTSTATUS", [], nil)

    {:ok, conn, 200, body} = get_response(conn)
    %{"FileStatuses" => _} = body |> Jason.decode!()

    Mint.HTTP.close(conn)
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
end
