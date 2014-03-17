require 'test_helper'
 
class KmvApiTest < ActiveSupport::TestCase

  test "get item's latest price report" do
  	name = "POTATO"
    data = KmvApi.get_price_history(name)
    assert( data.present?, "no report present for item: #{name} in Kmv Api")
  end
end