defmodule HdfsClientTest do
  use ExUnit.Case
  doctest HdfsClient

  test "greets the world" do
    with {:ok, conn} <- HdfsClient.connect( "hdp-node1.staging.fun-box.ru", 14000) do
      conn
      |> HdfsClient.authenticate("hadoop")
      |> HdfsClient.list("/")
    end
  end
end
