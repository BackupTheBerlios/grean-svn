class Tag < ActiveRecord::Base
  def self.destroy_by_names_if_zero_tagged(names)
    names.each do |name|
      tag = Tag.find_by_name(name)
      count = Tag.count_by_sql("SELECT COUNT(*) FROM tags_bookmarks WHERE tags_bookmarks.tag_id = #{tag.id}")
      tag.destroy if count == 0
    end
  end
end
