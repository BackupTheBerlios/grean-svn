class Bookmark < ActiveRecord::Base
  before_save :strip

  attr_accessible :url, :title, :notes

  # url
  validates_uniqueness_of :url
  validates_format_of :url, :with => %r<^http(s)?://[^/]+/>
  # title
  validates_presence_of :title

  protected
  # æ“ª‚Æ––”ö‚Ì‹ó”’•¶š‚ğíœ
  def strip
    self.url.strip!   if self.url
    self.title.strip! if self.title
    self.notes.strip! if self.notes
  end
end
