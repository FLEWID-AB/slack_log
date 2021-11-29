defmodule SlackLog.Formatter do
  @moduledoc """
  Formats a slack message depending on metadata and level
  """
  import Logger.Formatter, only: [format_date: 1, format_time: 1]

  @doc """
  Compose a new message
  """
  def format_message({level, message, timestamp, metadata} = info, show_meta) do
    blocks = []
      |> add_block(:header, info)
      |> add_block(:info, info)
      |> add_block(:divider)
      |> add_block(:message, info)
      |> add_block(:metadata, info, show_meta)

    %{blocks: blocks}
  end

  defp add_block(acc, :divider) do
    acc ++ [%{type: "divider"}]
  end
  defp add_block(acc, :header, {level, _, _, _}) do
    acc ++ [
      %{
        type: "header",
        text: %{
          type: "plain_text",
          text: get_header(level),
          emoji: true
        }
      }
    ]
  end
  defp add_block(acc, :info, {level, _, timestamp, _}) do
    acc ++ [%{
      type: "section",
      fields: [
        %{
          type: "mrkdwn",
          text: "*Priority:* #{Atom.to_string(level)}"
        },
        %{
          type: "mrkdwn",
          text: "*Timestamp:* #{parse_ts(timestamp)}"
        }
      ]
    }]
  end
  defp add_block(acc, :message, {_, message, _, _}) do
    acc ++ [%{
      type: "section",
      text: %{
        type: "plain_text",
        text: message,
        emoji: true
      }
    }]
  end
  defp add_block(acc, :metadata, {_, _, _, metadata}, fields) do
    meta = take_meta(metadata, fields)
    if Enum.empty?(meta) do
      acc
    else
      acc = acc
      |> add_block(:divider)

      acc ++ [%{
        type: "section",
        text: %{
          type: "mrkdwn",
          text: "*Metadata*"
        },
        fields: Enum.map(meta, fn {key, value} ->
          %{
            type: "mrkdwn",
            text: "*#{key}:* #{value}"
          }
        end)
      }]
    end
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

  defp get_header(level) do
    headers = get_headers()
    Keyword.get(headers, level, "New Log")
  end

  defp get_headers() do
    Application.get_env(:slack_log, :headers, [])
  end

  # Function that takes and stringifies the given params from a keyword list
  defp take_meta(_data, :none), do: []

  defp take_meta(data, :all), do: format_keyword_list(data)
  defp take_meta(data, nil), do: format_keyword_list(data)

  defp take_meta(data, fields) do
    data
    |> Keyword.take(fields)
    |> format_keyword_list
  end

  # Helper function that stringifies each {key, val} in a keyword list
  defp format_keyword_list(list) do
    list
    |> Enum.map(fn {k, v} -> {k, "#{inspect(v)}"} end)
  end
end
