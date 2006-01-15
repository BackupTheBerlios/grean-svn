module BookmarksHelper
  # notes
  def notes_html(notes)
    notes ? h(notes).gsub(/\r\n|\n|\r/, "<br />\n") : ''
  end
end
