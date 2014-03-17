require 'test_helper'
 
class BigBasketApiTest < ActiveSupport::TestCase

  test "crawl item page using id" do
  	id = "10000159"
    page = BigBasketApi.get_item_page(id)
    assert( page.price > 0.0, "price is not greater than 0 for id: #{id}" )
    assert( page.unit.present?, "unit not present for id: #{id}")
    assert( page.name.present?, "item name not present for id: #{id}")
    assert( page.id == id, "item id not matching for id: #{id}")
  end
end