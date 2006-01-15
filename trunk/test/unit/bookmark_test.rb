require File.dirname(__FILE__) + '/../test_helper'

class BookmarkTest < Test::Unit::TestCase
  fixtures :bookmarks

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Bookmark, bookmarks(:first)
  end
end
