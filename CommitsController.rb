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

class CommitsController < OSX::NSObject
  ib_outlet :commits_table
  ib_outlet :branch_select
  ib_outlet :paging_segment
  ib_outlet :commit_details
  
  def awakeFromNib  
    @repo_location = ENV['PWD'].nil? ? '' : ENV['PWD']
    @current_commit_offset = 0
    @offset = 50
    @active_commit = nil
    @icons = {}
    
    if(fetch_git_repository)
      setup_commit_detail_view
      fetch_commits_for :master, @offset
      setup_branches_menu
      setup_paging_control
      @commits_table.reloadData
    end
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
    fetch_commits_for(:master, @offset, @current_commit_offset)
    @commits_table.reloadData
    
    
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
    diffs = []
    doc = @commit_details.mainFrame.DOMDocument
    set_html("message", active_commit.message)
    set_html("hash", active_commit.id)
    
    if Time.now.day == active_commit.committed_date.day
      cdate = active_commit.committed_date.strftime("Today %I:%m %p")
    else
      cdate = active_commit.committed_date.strftime("%A, %B %d %I:%m %p")
    end
    set_html("date", cdate)
    
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
      unless diff.deleted_file
        diff_div = doc.createElement('div')
        diff_div.setAttribute__('class', 'diff')
        diff_div.setAttribute__('id', "diff-#{i}")
        diff_div.setInnerHTML(%(
          <h3>#{File.basename(diff.b_path)}</h3>
          <pre><code>#{CGI.escapeHTML(diff.diff)}</pre></code>
        ))
        diff_list.appendChild(diff_div)
      end
    end
  end
  
  # DataSource Methods
  def numberOfRowsInTableView(table_view)
    @commits ? @commits.size : 0
  end
  
  # There is something fishy with ImageTextCell and this method so 
  # we set the commit object to be used in dataElementForCell and return nil
  def tableView_objectValueForTableColumn_row(table_view, table_column, row)
    @commit = @commits[row]
    return nil
  end
  
  # ImageTextCell data methods
  def primaryTextForCell_data(cell, data)
    data.message.gsub(/\n/, ' ').to_s
  end
  
  def secondaryTextForCell_data(cell, data)
    %(by #{data.committer.name} on #{data.committed_date.strftime("%A, %b %d, %I:%m %p")})
  end
  
  def iconForCell_data(icon, data)
    gravatar = NSURL.URLWithString("http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest(data.committer.email)}&size=36")
    NSImage.alloc.initWithContentsOfURL(gravatar)
  end
  
  def dataElementForCell(cell)
    @commit
  end
  
  # def connection_didRecieveResponse(connection, response)
  #   @image_data.length = 0
  # end
  # 
  # def connection_didReceiveData(connection, data)
  #   @image_data.appendData(data)
  # end
  # 
  # def connectionDidFinishLoading(connection)
  #   
  #   @commits_table.reloadData
  #   @connection.release
  #   @image_data.release
  # end
  
  private
  
  def active_commit
    @commits[@commits_table.selectedRow]
  end
  
  def fetch_git_repository
    begin
      @repo = Grit::Repo.new(@repo_location)
    rescue Grit::InvalidGitRepositoryError
      return false
    end
  end
  
  def fetch_commits_for(branch, quanity, offset = 0)
    @commits = @repo.commits(branch, quanity, offset)
  end
  
  def setup_branches_menu
    @branch_select.removeAllItems
    @repo.branches.each do |branch|
      @branch_select.addItemWithTitle(branch.name)
    end
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
end
