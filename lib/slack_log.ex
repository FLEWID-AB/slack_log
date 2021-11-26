defmodule SlackLog do
  @moduledoc """
  `SlackLog` is a custom backend for the elixir `:logger` application.
  Based on the configuration it will post errors to specified Slack hooks
  """
  @behaviour :gen_event

  @type level ::Logger.level()
  @type metadata :: [atom]

  @default_format "$time $metadata[$level] $message\n"

  alias SlackLog.Messenger

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event({level, _pid, {Logger, msg, ts, meta}}, %{level: min_level, metadata_filter: metadata_filter} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt and metadata_matches?(meta, metadata_filter) do
      log_event(level, msg, ts, meta, state)
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_info(_message, state) do
    {:ok, state}
  end

  defp log_event(_level, _msg, _ts, _meta, %{slack_url: nil} = state) do
    {:ok, state}
  end
  defp log_event(level, msg, ts, meta, %{slack_url: slack_url, metadata: metadata} = state) when is_binary(slack_url) do
    message = SlackLog.Formatter.format_message(level, msg, ts, take_params(meta, metadata)) |> Jason.encode!()
    Messenger.send(slack_url, message)

    {:ok, state}
  end


  def metadata_matches?(_meta, nil), do: true
  def metadata_matches?(_meta, []), do: true
  def metadata_matches?(meta, [{key, val} | tail]) do
    case Keyword.fetch(meta, key) do
      {:ok, ^val} ->
        metadata_matches?(meta, tail)

      _ -> false
    end
  end

  defp configure(name, opts) do
    state = %{
      name: nil,
      format: nil,
      level: nil,
      metadata: nil,
      metadata_filter: nil,
      slack_url: nil
    }

    configure(name, opts, state)
  end

  # Function that takes and stringifies the given params from a keyword list
  defp take_params(_data, :none), do: ""

  defp take_params(data, :all), do: format_keyword_list(data)
  defp take_params(data, nil), do: format_keyword_list(data)

  defp take_params(data, fields) do
    data
    |> Keyword.take(fields)
    |> format_keyword_list
  end

  # Helper function that stringifies each {key, val} in a keyword list
  defp format_keyword_list(list) do
    list
    |> Enum.reduce("", fn {k, v}, acc -> "#{k}: #{inspect(v)}\n" <> acc end)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    metadata = Keyword.get(opts, :metadata, [])
    format_opts = Keyword.get(opts, :format, @default_format)
    format = Logger.Formatter.compile(format_opts)
    metadata_filter = Keyword.get(opts, :metadata_filter)
    slack_url = Keyword.get(opts, :slack_url)

    %{
      state
      | name: name,
        format: format,
        level: level,
        metadata: metadata,
        metadata_filter: metadata_filter,
        slack_url: slack_url
    }
  end
end
