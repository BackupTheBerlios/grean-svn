module BookmarksHelper
  # notes
  def notes_html(notes)
    notes ? h(notes).gsub(/\r\n|\n|\r/, "<br />\n") : ''
  end

  # tags
  def tags_html(tags)
    tags.collect! do |tag|
      h(tag.name)
    end
    tags.join(' ')
  end
end
