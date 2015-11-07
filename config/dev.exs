# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# You can configure for your application as:
#
#     config :edenex, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:edenex, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info

# These should be set "for realsies" in dev.secret.exs.
config :edenex, eve_key_id: "1234567890"
config :edenex, verification_code: "ABC...789"

