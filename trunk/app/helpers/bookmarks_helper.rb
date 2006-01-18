module BookmarksHelper
  # notes
  def notes_html(notes)
    notes ? h(notes).gsub(/\r\n|\n|\r/, "<br />\n") : ''
  end

  # tags
  def tags_html(tag_names)
    ue_params_tags = params[:tags] ? params[:tags].collect { |t| u(t) } : nil
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
    %|<a href="#{url}" title="?B hot entry">#{domain}</a>|
  end

  # ?B entry
  def hatena_bookmark_entry_link(url)
    entry_url = HatenaBookmark.entry_url(url)
    %|<a href="#{entry_url}" title="?B entry">?B</a>|
  end

  # del.icio.us history
  def delicious_history_link(url)
    history_url = Delicious.history_url(url)
    %|<a href="#{history_url}" title ="del.icio.us history">del.icio.us</a>|
  end
end
