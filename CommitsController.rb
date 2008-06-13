#
#  CommitsController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/2/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#
 
require 'osx/cocoa'
require 'md5'
require 'cgi'
 
def gravatar_url(email, size=36, default="x-img://default")
  hash = MD5.hexdigest(email.downcase)
  edefault = default.gsub(/[^a-zA-Z0-9_-]/) { |s| "%%%02X" % s[0]}
  NSURL.URLWithString("http://www.gravatar.com/avatar.php?gravatar_id=#{hash}&s=#{size}&d=#{edefault}")
end
 
class CommitsController < OSX::NSObject
  ib_outlet :commits_table
  ib_outlet :branch_select
  ib_outlet :paging_segment
  ib_outlet :commit_details
  ib_outlet :application_controller
  
  def awakeFromNib  
    @current_commit_offset = 0
    @offset = 50
    @active_commit = nil
    @branch = :master
    @icon_queue = NSOperationQueue.alloc.init
    @icon_url_map = {}
    @icons = Hash.new do |hash, email|
      url = gravatar_url(email)
      @icon_url_map[url] = email
      @icon_queue.addOperation(ImageLoadOperation.alloc.initWithURL_delegate(url, self))
      hash[email] = NSImage.imageNamed(NSImageNameUser)
    end
    
    if fetch_git_repository
      fetch_git_branch
      setup_commit_detail_view
      fetch_commits_for(@branch, @offset)
      setup_branches_menu
      setup_paging_control
      @commits_table.reloadData
    end
  end
  
  ib_action :perform_utility_action
  def perform_utility_action(segment)
    tag = segment.cell.tagForSegment(segment.selectedSegment)
    case tag
      when 0 then refresh_commits(segment)
      when 1 then @application_controller.show_info_panel(segment)
    end
  end
  
  ib_action :refresh_commits
  def refresh_commits(sender)
    refresh
  end
  
  ib_action :page_commits
  def page_commits(segment)
    tag = segment.cell.tagForSegment(segment.selectedSegment)
    case tag
      when 0 then @current_commit_offset -= @offset
      when 1 then @current_commit_offset = 0
      when 2 then @current_commit_offset += @offset
    end
    
    @current_commit_offset = 0 if @current_commit_offset == -(@offset)
    fetch_commits_for(@branch, @offset, @current_commit_offset)
    @commits_table.reloadData
    
    select_latest_commit  
    
    if @commits.size == 0 || @current_commit_offset == 0
      @paging_segment.setEnabled_forSegment(false, 0)
      @paging_segment.setEnabled_forSegment(true, 2) unless @commits.size == 0
    elsif ((@current_commit_offset >= @offset) && (@commits.size % @offset == 0))
      @paging_segment.setEnabled_forSegment(true, 0)
      @paging_segment.setEnabled_forSegment(true, 2)
    elsif @commits.size % @offset != 0
      @paging_segment.setEnabled_forSegment(true, 0)
      @paging_segment.setEnabled_forSegment(false, 2)
    end
  end
  
  def tableViewSelectionDidChange(notification)
    update_main_document
    scrollView = @commit_details.mainFrame.frameView.documentView.enclosingScrollView
    scrollView.documentView.scrollPoint([0,0])
  end
  
  # DataSource Methods
  def numberOfRowsInTableView(table_view)
    @commits ? @commits.size : 0
  end
  
  def tableView_objectValueForTableColumn_row(table_view, table_column, row)
    @commits[row].message.split(/\n/, 2).first.to_s
  end
  
  objc_method :tableView_willDisplayCell_forTableColumn_row, 'v@:@@@i'
  def tableView_willDisplayCell_forTableColumn_row(table_view, cell, table_column, row)
    commit = @commits[row]
    cell.subtitle = %(by #{commit.author.name} on #{commit.authored_date.to_system_time})
    cell.gravatarImage = @icons[commit.author.email]
  end
  
  def webView_didFinishLoadForFrame(view, frame)
    select_latest_commit
  end
  
  def webView_contextMenuItemsForElement_defaultMenuItems(view, element, defaultMenuItems)
    defaultMenuItems.select do |item|
      # WebMenuItemTagCopy = 8
      # WebMenuItemTagCut = 13
      # WebMenuItemTagPaste = 14
      [8, 13, 14].include? item.tag
    end
  end
  
  def imageLoadForURL_didFinishLoading(url, image)
    email = @icon_url_map[url]
    @icons[email] = image
    @commits_table.rowsInRect(@commits_table.enclosingScrollView.documentVisibleRect).to_range.each do |i|
      if @commits[i].author.email == email
        @commits_table.setNeedsDisplayInRect(@commits_table.rectOfRow(i))
      end
    end
  end
  
  def imageLoadForURL_didFailWithError(url, error)
    STDERR.puts "Async image load failed for URL: #{url}\n#{error}"
  end
 
  def select_latest_commit
    indices = @commits_table.selectedRowIndexes
    if indices.isEqualToIndexSet(NSIndexSet.indexSetWithIndex(0))
      @commits_table.selectRowIndexes_byExtendingSelection(NSIndexSet.indexSet, false)
    end
    @commits_table.selectRowIndexes_byExtendingSelection(NSIndexSet.indexSetWithIndex(0), false)
    @commits_table.scrollRowToVisible(0)
  end
  
  def update_main_document
    return unless active_commit
    diffs = []
    doc = @commit_details.mainFrame.DOMDocument
    title, message = active_commit.message.split("\n", 2)
    set_html("title", title.escapeHTML.strip.gsub("\n", "<br />"))
    if message
      set_html("message", message.escapeHTML.strip.gsub("\n", "<br />"))
      show_element("message")
    else
      hide_element("message")
    end
    set_html("hash", active_commit.id)
 
    if Time.now.day == active_commit.authored_date.day
      cdate = active_commit.authored_date.to_system_time(:time)
    else
      cdate = active_commit.authored_date.to_system_time
    end
    set_html("date", "#{cdate} by #{active_commit.author.name}")
 
    file_list = doc.getElementById('files')
    diff_list = doc.getElementById('diffs')
    diff_list.setInnerHTML("")
    file_list.setInnerHTML("")
 
    active_commit.diffs.each_with_index do |diff, i|
      li = doc.createElement('li')
      li.setAttribute__('id', "item-#{i}")
      li.setAttribute__('class', 'add') if diff.new_file
      li.setAttribute__('class', 'delete') if diff.deleted_file
      li.setInnerHTML(%(<a href="#diff-#{i}" class="">#{diff.b_path}</a>))
      file_list.appendChild(li)
 
      unless diff.deleted_file or diff.diff.nil?
        diff_div = doc.createElement('div')
        diff_div.setAttribute__('class', 'diff')
        diff_div.setAttribute__('id', "diff-#{i}")
 
        colored_diff = []
        html = CGI.escapeHTML(diff.diff)
        html.each_line do |line|
          if line =~ /^\+/
            colored_diff << %(<div class="addline">#{line}</div>)
          elsif line =~ /^\-/
            colored_diff << %(<div class="removeline">#{line}</div>)
          elsif line =~ /^@/
            colored_diff << %(<div class="meta">#{line}</div>)
          else
            colored_diff << line
          end
        end
 
        diff_div.setInnerHTML(%(
          <h3>#{File.basename(diff.b_path)}</h3>
          <pre><code class="diffcode">#{colored_diff}</pre></code>
        ))
        diff_list.appendChild(diff_div)
      end
    end
  end
  
  def refresh
    current_commit = active_commit && active_commit.id
    @branch = @branch_select.titleOfSelectedItem
    fetch_commits_for(@branch, @offset)
    
    @commits_table.reloadData
    select_latest_commit
  end
  
  def swap_branch(foo)
    @branch = foo.title
    fetch_commits_for(@branch, @offset)
    @commits_table.reloadData
    select_latest_commit
  end
  
  def search_commits(category, query)
    unless query == ""
      repo = @application_controller.repo
      case category.downcase.to_sym
        when :message
         @commits = Grit::Commit.find_all(repo, nil, {:grep => query, :i => true})
        when :committer
         @commits = Grit::Commit.find_all(repo, nil, {:committer => query})
        when :author
         @commits = Grit::Commit.find_all(repo, nil, {:author => query})
        when :sha1
          @commits = [repo.commit(query)]
        when :path
          @commits = repo.log(@branch, query)
      end
      @commits_table.reloadData
      select_latest_commit
    else
      refresh
    end
  end
  
  private
  
  def active_commit
    @commits[@commits_table.selectedRow]
  end
  
  def fetch_git_repository
    begin
      @repo = Grit::Repo.new(REPOSITORY_LOCATION)
    rescue Grit::InvalidGitRepositoryError
      return false
    end
  end
  
  def fetch_git_branch
    head = @repo.head || @repo.heads.first
    @branch = head.name.to_sym
  end
  
  def fetch_commits_for(branch, quanity, offset = 0)
    @commits = @repo.commits(branch, quanity, offset)
  end
  
  def setup_branches_menu
    @branch_select.removeAllItems
    @repo.branches.each do |branch|
      @branch_select.addItemWithTitle(branch.name)
    end
    @branch_select.selectItemWithTitle(@branch)
  end
  
  def setup_paging_control
    if @commits.size < @offset
      @paging_segment.setEnabled_forSegment(false, 2)
      @paging_segment.setEnabled_forSegment(false, 1)
    end
  end
  
  def setup_commit_detail_view
    commit_detail = File.join(NSBundle.mainBundle.bundlePath, "Contents", "Resources", "commit.html")
    @commit_details.mainFrame.loadRequest(NSURLRequest.requestWithURL(NSURL.fileURLWithPath(commit_detail)))
  end
  
  def set_html(element, html)
    @commit_details.mainFrame.DOMDocument.getElementById(element).setInnerHTML(html)
  end
  
  def show_element(element)
    element = @commit_details.mainFrame.DOMDocument.getElementById(element)
    element.style.removeProperty("display")
  end
  
  def hide_element(element)
    element = @commit_details.mainFrame.DOMDocument.getElementById(element)
    element.style.setProperty_value_priority("display", "none", nil)
  end
end
