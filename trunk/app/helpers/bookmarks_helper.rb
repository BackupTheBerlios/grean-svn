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

  # ?B hot entry
  def hatena_bookmark_hot_entry_link(url)
    url, domain = HatenaBookmark.entrylist_url_and_domain(url)
    %|<a href="#{url}" title="?B hot entry">#{domain}</a>|
  end
end
