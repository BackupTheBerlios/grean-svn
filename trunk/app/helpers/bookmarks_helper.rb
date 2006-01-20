module BookmarksHelper
  def html_title
    title = "Bookmarks: #{controller.action_name}"
    if controller.action_name == 'list'
      if params[:tags]
        title += ' Tag: ' + params[:tags].join('/')
      end
      if params[:search]
        title += ' Search: ' + params[:search]
      end
    end
    title
  end

  def escape_url(strings)
    strings ? strings.collect { |s| u(s) } : nil
  end

  # notes
  def notes_html(notes)
    if notes
      if params[:search]
        highlight(h(notes), h(params[:search])).gsub(/\r\n|\n|\r/, "<br />\n")
      else
        h(notes).gsub(/\r\n|\n|\r/, "<br />\n")
      end
    else
      ''
    end
  end

  # tag add
  def add_tag(tag_name)
    ((params[:tags] || []) + [tag_name]).uniq
  end
  # <a href="">tag1</a>
  def tag_link(tag_name)
    if params[:tags] && params[:tags].include?(tag_name)
      h(tag_name)
    else
      link_to(h(tag_name), { :action => 'list', :tags => escape_url(add_tag(tag_name)), :search => params[:search] })
    end
  end
  # <a href="">tag1</a> <a href="">tag2</a> ...
  def tag_links(tag_names, separator = ' ')
    tag_names.collect { |tag_name| tag_link(tag_name) }.join(separator)
  end
  # tag remove
  # <a href="">tag1</a> <a href="">tag2</a> ...
  def tag_remove_links(tag_names, separator = ' ')
    links = tag_names.collect do |tag_name|
      removed_tags = params[:tags] - [tag_name]
      removed_tags = nil if removed_tags.length == 0
      link_to(h(tag_name), { :action => 'list', :tags => escape_url(removed_tags), :search => params[:search] })
    end
    links.join(separator)
  end

  # ?B hot entry
  def hatena_bookmark_hot_entry_link(url)
    url, domain = HatenaBookmark.entrylist_url_and_domain(url)
    link_to(h(domain), url, :title => '?B hot entry')
  end

  # ?B entry
  def hatena_bookmark_entry_link(url)
    entry_url = HatenaBookmark.entry_url(url)
    link_to('?B', entry_url, :title => '?B entry')
  end

  # del.icio.us history
  def delicious_history_link(url)
    history_url = Delicious.history_url(url)
    link_to('del.icio.us', history_url, :title => 'del.icio.us history')
  end
end
