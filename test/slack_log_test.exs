defmodule SlackLogTest do
  use ExUnit.Case, async: false
  require Logger

  @backend {SlackLog, :test}

  setup do
    bypass = Bypass.open
    url = "http://localhost:#{bypass.port}/hook"
    Logger.add_backend(@backend, flush: true)
    config(level: :debug, slack_url: url)

    on_exit(fn ->
      :ok = Logger.remove_backend(@backend)
    end)
    {:ok, %{bypass: bypass}}
  end

  test "it posts a log to Slack", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/hook" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, "ok")
    end
    Logger.debug("This is going to Slack")
    Logger.flush()
    :timer.sleep(100)
  end

  describe "metadata_matches?/2" do
    test "it returns true if nil or empty" do
      assert SlackLog.metadata_matches?([test: true], nil)
      assert SlackLog.metadata_matches?([test: true], [])
    end

    test "it returns true if value is in metadata" do
      metadata = [test: 1, test2: 2]
      assert SlackLog.metadata_matches?(metadata, [test: 1])
      assert SlackLog.metadata_matches?(metadata, [test2: 2])
    end

    test "it returns false if metadata does not match" do
      metadata = [test: 1, test2: 2]
      refute SlackLog.metadata_matches?(metadata, [test: 2])
    end
  end


  defp config(opts) do
    :ok = Logger.configure_backend(@backend, opts)
  end

  defp log do
    File
  end
end
