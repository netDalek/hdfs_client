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

  def connect(host, port \\ 80, scheme \\ :http) do
    with {:ok, conn} <- Mint.HTTP.connect(scheme, host, port) do
      opts = %{}
      {:ok, {conn, opts}}
    end
  end

  def authenticate({conn, opts}, user) do
    {conn, Map.put(opts, :user, user)}
  end

  def list({conn, opts}, path) do
    Mint.HTTP.request(conn, "GET", "webhdfs/v1#{path}?op=LISTSTATUS&user.name=#{opts.user}", [], "")
  end
end
