defmodule EdenexXMLTest do
  import Edenex.XML
  require Record

  use ExUnit.Case
  doctest Edenex.XML

  @corp_asset_xml """
<?xml version='1.0' encoding='UTF-8'?>
<eveapi version="2">
  <currentTime>2015-11-07 21:12:32</currentTime>
  <result>
    <rowset name="assets" key="itemID" columns="itemID,locationID,typeID,quantity,flag,singleton">
      <row itemID="1018882287314" locationID="60010336" typeID="587" quantity="2" flag="62" singleton="0" />
      <row itemID="178452021" locationID="66005213" typeID="27" quantity="1" flag="75" singleton="1" rawQuantity="-1">
        <rowset name="contents" key="itemID" columns="itemID,typeID,quantity,flag,singleton">
          <row itemID="298893043" typeID="31716" quantity="4" flag="116" singleton="0" />
          <row itemID="361771522" typeID="31681" quantity="1" flag="4" singleton="1" rawQuantity="-1" />
        </rowset>
      </row>
    </rowset>
  </result>
  <cachedUntil>2015-11-08 03:09:32</cachedUntil>
</eveapi>
                  """

  #
  #
  # [name: :undefined, expanded_name: [], nsinfo: [],
  #  namespace: {:xmlNamespace, [], []}, parents: [], pos: :undefined,
  #  attributes: [], content: [], language: [], xmlbase: [],
  #  elementdef: :undeclared]
  #
  #
  defp xml_obj(content) do
    { xml, _rest } = :xmerl_scan.string(to_char_list(content))
    List.first(:xmerl_xpath.string('//rowset', xml))
  end

  test "process_rowset returns a list of maps" do
    xml = xml_obj(@corp_asset_xml)
    result = Edenex.XML.process_rowset(xml)
    assert result |> is_list, "result was not a list"
    first = List.first(result)
    assert first |> is_map, "first result was not a map"
    assert first[:itemID] == '1018882287314'
    assert first[:nested] == nil
    last = List.last(result)
    assert last[:itemID] == '178452021'
    assert last[:nested] != nil
    # locationID="66005213" typeID="27" quantity="1" flag="75" singleton="1" rawQuantity="-1">
  end
end
