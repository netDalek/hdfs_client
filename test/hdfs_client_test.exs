defmodule HdfsClientTest do
  use ExUnit.Case
  doctest HdfsClient

  test "list" do
    with {:ok, conn} <- HdfsClient.open("hdp-node1.staging.fun-box.ru") do
      {:ok, conn, list} = HdfsClient.list(conn, "/")

      assert 344 ==
               list
               |> Enum.map(&Map.get(&1, "pathSuffix"))
               |> Enum.join()
               |> String.length()

      {:ok, conn, list} = HdfsClient.list(conn, "a2p")
      assert 24 == Enum.count(list)

      HdfsClient.close(conn)
    end
  end

  test "info" do
    with {:ok, conn} <- HdfsClient.open("hdp-node1.staging.fun-box.ru") do
      {:ok, conn, info} = HdfsClient.info(conn, "/a2p/templates.json")
      assert %{"type" => "FILE"} = info
      HdfsClient.close(conn)
    end
  end

  test "read" do
    with {:ok, conn} <- HdfsClient.open("hdp-node1.staging.fun-box.ru") do
      {:ok, conn, body} = HdfsClient.read_all(conn, "/a2p/templates.json")
      Jason.decode!(body)
      HdfsClient.close(conn)
    end
  end
end
