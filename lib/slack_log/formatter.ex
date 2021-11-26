defmodule SlackLog.Formatter do
  @moduledoc """
  Formats a slack message depending on metadata and level
  """
  import Logger.Formatter, only: [format_date: 1, format_time: 1]

  @doc """
  Compose a new message
  """
  def format_message(level, message, timestamp, metadata) do
    %{
      text: "*Incoming Log*",
      attachments: [
        %{
          author_name: "SlackLog",
          color: get_color(level),
          fields: get_fields(level, message, timestamp, metadata)
        }
      ]
    }
  end

  defp get_fields(level, message, timestamp, metadata) do
    [
      %{
        title: "Priority",
        value: Atom.to_string(level),
        short: false
      },
      %{
        title: "Timestamp",
        value: parse_ts(timestamp),
        short: false
      },
      %{
        title: "Metadata",
        value: metadata
      },
      %{
        title: "Message",
        value: ~s(```#{message}```)
      }
    ]
  end

  defp parse_ts({date, time}) do
    d = date
      |> format_date()
      |> to_string()

    t = time
      |> format_time()
      |> to_string()

    d <> " " <> t
  end

  defp get_color(level) do
    cond do
      level == :warning -> "#FFCF52"
      level in [:error, :critical, :alert, :emergency] -> "#FF5252"
      true -> "#8FC6F6"
    end
  end
end
