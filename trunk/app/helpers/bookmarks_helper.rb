module BookmarksHelper
  def escape_url(strings)
    strings ? strings.collect { |s| u(s) } : nil
  end

  # notes
  def notes_html(notes)
    notes ? h(notes).gsub(/\r\n|\n|\r/, "<br />\n") : ''
  end

  # tags
  def tags_html(tag_names)
    ue_params_tags = escape_url(params[:tags])
    tag_names.collect! do |tag|
      if ue_params_tags
        if params[:tags].include? tag
          h(tag)
        else
          link_to h(tag), :action => 'list', :tags => ue_params_tags + [u(tag)]
        end
      else
        link_to h(tag), :action => 'list', :tags => u(tag)
      end
    end
    tag_names.join(' ')
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
