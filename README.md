# SlackLog

SlackLog is a library that borrows heavily from [logger_file_backend](https://github.com/onkel-dirtus/logger_file_backend) to allow for custom logging to defined Slack channels.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `slack_log` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:slack_log, "~> 0.1.0"}
  ]
end
```

## Configuration

`SlackLog` is a custom backend for elixir's `:logger` application. 
To configure logging to a Slack channel, you need to define the backend in the `:logger` configuration.

Example `config.exs`:

```elixir
config :logger,
	backends: [{SlackLog, :error_log}]
	
# Configure the error logger
# slack_url is the url you receive from Slack when setting up your webhook
config :logger, :error_log,
	slack_url: "https://url_for_slack_hook",
	level: :error,
	metadata: [:file, :line, :function]
```

This configuration - apart from slack_url - follows the same syntax as `logger_file_backend`, so it is possible to use one configuration for both backends. (e. g. when you want to log levels to different files, but also want to log errors to Slack.

The slack_url is defined in every backend configuration, so that different metadata filters or log levels can be posted to different channels.

It supports the following configuration values:

* `slack_url` the url to the custom Slack Webhook to send the messages to
* `level` the minimum log level to send
* `metadata` a list of atoms for the metadata to include in messages
* `metadata_filter` a keyword list with metadata and value to filter out which messages to log

Example `metadata_filter`:

```elixir
config :logger, :user_activity_log,
	level: :debug,
	metadata_filter: [area: :user, action: [:login, :sign_up]]
```
In the example above, it would only send out log events that have `area: :user` and the metadata `:action` is one of `:login` or `:sign_up`.
If one of these conditions do not match, the event will not be sent to your specified channel.

### Defining custom headers

`SlackLog` allows to configure custom headers (including icons) for different Log levels.

Example `config.exs`:

```elixir
config :slack_log, :headers,
  emergency: ":skull: New Emergency!!!",
  alert: ":skull: New Alert!!!",
  critical: ":x: New Critical Error!!!",
  error: ":x: New Error",
  warning: ":x: New Warning",
  notice: ":information_source: New Notice",
  info: ":information_source: New Info",
  debug: ":information_source: New Debug Message"
```