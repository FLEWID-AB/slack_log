defmodule SlackLog.Messenger do
  @moduledoc """
  Sends out log events through http requests to the configured Slack Webhook
  """
  use HTTPoison.Base

  def process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end

  def process_request_headers(headers) do
    headers ++ [{"Content-Type", "application/json"}]
  end

  @doc """
  Send message to Slack webhook
  """
  def send(url, message) do
    post(url, message)
  end
end
