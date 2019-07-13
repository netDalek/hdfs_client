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
end
