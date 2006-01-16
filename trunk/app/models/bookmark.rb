class Bookmark < ActiveRecord::Base
  acts_as_taggable

  before_save :strip

  attr_accessible :url, :title, :notes

  # url
  validates_uniqueness_of :url
  validates_format_of :url, :with => %r<^http(s)?://[^/]+/>
  # title
  validates_presence_of :title

  # acts_as_taggable
  def tags_str
    self.tags.collect { |t| t.name }.join(' / ')
  end
  def set_tags(param_tags)
    tags_array = param_tags.split('/').collect{ |t| t.strip }.delete_if{ |t| t.length == 0 }
    self.tag(tags_array, :clear => true)
  end

  protected
  # 先頭と末尾の空白文字を削除
  def strip
    self.url.strip!   if self.url
    self.title.strip! if self.title
    self.notes.strip! if self.notes
  end
end
