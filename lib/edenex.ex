defmodule Edenex do
  def key_id do
    Application.get_env(:edenex, :eve_key_id)
  end

  def verification_code do
    Application.get_env(:edenex, :verification_code)
  end
end
