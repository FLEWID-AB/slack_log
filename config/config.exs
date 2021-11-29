use Mix.Config

config :slack_log, :headers,
  emergency: ":skull: New Emergency!!!",
  alert: ":skull: New Alert!!!",
  critical: ":x: New Critical Error!!!",
  error: ":x: New Error",
  warn: ":x: New Warning",
  warning: ":x: New Warning",
  notice: ":information_source: New Notice",
  info: ":information_source: New Info",
  debug: ":information_source: New Debug Message"
