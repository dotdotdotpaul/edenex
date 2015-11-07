defmodule Edenex.XML do
  require Record
  Record.defrecord :xmlElement,
                   Record.extract(:xmlElement,
                                  from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute,
                   Record.extract(:xmlAttribute,
                                  from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,
                   Record.extract(:xmlText, from_lib:
                                  "xmerl/include/xmerl.hrl")



  @url "https://api.eveonline.com"
  @user_agent [ { "User-agent",
                  "Edenex (http://github.com/dotdotdotpaul/edenex)" } ]

  def corp_wallet_transactions(account_key \\ 1000) do
    make_call_with_auth("corp/WalletTransactions", %{accountKey: account_key})
  end
  def corp_asset_list do
    make_call_with_auth("corp/AssetList")
  end

  @doc """
  Make call to given endpoint, with given args, merging in the authentication
  keys needed (pulled from the Edenex module), then process the XML response
  to return a list of hashes representing each row returned from the call.
  """
  def make_call_with_auth(endpoint, args \\ %{}) do
    endpoint
    |> make_call(Dict.merge(args, %{ keyID: Edenex.key_id,
                                     vCode: Edenex.verification_code }))
  end

  
  @doc """
  Make call to given endpoint, with given args, then process the XML response
  to return a list of hashes representing each row returned from the call.
  """
  def make_call(endpoint, args \\ %{}) do
    "#{@url}/#{endpoint}.xml.aspx"
    |> HTTPoison.post({:form, Enum.map(args, &(&1))}, @user_agent)
    |> process_response
  end 

  @doc """
  Process an HTTPoison response, parsing the XML to return the resulting rows.
  """
  def process_response({:ok, response}) do
    IO.puts(response.body)
    { xml, _rest } = :xmerl_scan.string(to_char_list(response.body))
    # Pull the list of columns from the rowset's attributes, split on comma.
    List.first(:xmerl_xpath.string('//rowset', xml)) |> process_rowset
  end

  def process_rowset(rowset) do
    # Iterate over all its rows; recurse if a row contains another rowset.
    rowset |> xmlElement(:content)
           |> Enum.filter(fn(x) -> xmlElement(x, :name) == :row end)
           |> Enum.map(fn(x) -> extract_from_row(x) end)
  end

  def extract_from_row(element) do
    attrs = xmlElement(element, :attributes)
    row_map = attrs
      |> Enum.map(fn(x) -> { xmlAttribute(x, :name),
                             xmlAttribute(x, :value) } end)
      |> Enum.into(%{})
    children = Enum.filter(xmlElement(element, :content),
                           fn(x) -> xmlElement(x, :name) == :rowset end)
    if Enum.count(children) > 0 do
      row_map = Map.put_new(row_map, :nested,
                            Enum.map(children, fn(x) -> process_rowset(x) end))
    end
    row_map
  end

end

