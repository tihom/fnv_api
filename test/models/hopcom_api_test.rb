require 'test_helper'
 
class HopcomApiTest < ActiveSupport::TestCase

  test "get latest rate list" do
  	data  = HopcomApi.get_latest_price
  	assert(data.present? , "no data read from current rate list on Hopcom")
  end
end