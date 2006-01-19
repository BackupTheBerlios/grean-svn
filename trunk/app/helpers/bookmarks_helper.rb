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

  # tags
  def tag_filter_add_links(tag_names)
    if controller.action_name == 'list' && params[:tags]
      ue_params_tags = escape_url(params[:tags]) # Tag filter
      add_links = tag_names.collect do |tag|
        if params[:tags].include? tag
          h(tag)
        else
          link_to(h(tag), { :action => 'list', :tags => ue_params_tags+[u(tag)], :search => params[:search] }, :title => 'Add Tag filter')
        end
      end
      add_links.join(' ')
    else
      add_links = tag_names.collect do |tag|
        link_to(h(tag), :action => 'list', :tags => u(tag), :search => params[:search])
      end
      add_links.join(' ')
    end
  end
  def tag_filter_remove_links(tag_names)
    ue_params_tags = escape_url(params[:tags]) # Tag filter
    remove_links = tag_names.collect do |tag|
      removed_tags = ue_params_tags - [u(tag)]
      removed_tags = nil if removed_tags.length == 0
      link_to(h(tag), { :action => 'list', :tags => removed_tags, :search => params[:search] }, :title => 'Remove Tag filter')
    end
    remove_links.join(' ')
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
