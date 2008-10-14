#
#  TreeController.rb
#  GitNub
#
#  Created by Justin Palmer on 9/30/08.
#  Copyright (c) 2008 ENTP <http://hoth.entp.com>. All rights reserved.
#

require 'osx/cocoa'
OSX.ns_import 'GNFileSystemItem'
OSX.ns_import 'GNTreeDataSource'
require 'fileutils'

class TreeController < OSX::NSObject
  IMAGE_MIMES = ["image/png", "img/jpeg", "image/jpg", "image/gif", "img/bmp"]
  ELEMENTS = {
    :blame => 'blame',
    :list  => 'blame-list'
  }
  
  ib_outlet :tree_outline
  ib_outlet :file_canvas
  ib_outlet :tree_data_source
  ib_outlet :main_canvas

  
  def awakeFromNib
    setup_web_view
    dsource = GNTreeDataSource.alloc.init
    @tree_outline.setDataSource(dsource)
    @tree_outline.setDelegate(dsource)
    @tree_outline.expandItem(@tree_outline.itemAtRow(0))
    
  	NSNotificationCenter.defaultCenter.objc_send(:addObserver, self,
  		:selector, :item_was_selected,
  		:name, "NSOutlineViewSelectionDidChangeNotification",
  		:object, @tree_outline)
  		
  	Notify.on 'branch_was_changed' do |info|
  	  #working
	  end
  end

  
  def item_was_selected(notification)
    outline_view = notification.object
    item = outline_view.itemAtRow(outline_view.selectedRow)
    unless item.nil?
      Thread.start do
        doc    = @main_view.mainFrame.DOMDocument
        app    = NSApplication.sharedApplication.delegate
        branch = app.active_branch.to_s
        file   = item.fullPath.sub(app.repository_location, '').to_s
        commit = app.repo.commit(branch)
        blob   = commit.tree/file
        
        set_html('title', File.basename(file))
        element = doc.getElementById(ELEMENTS[:blame])
        element.setInnerHTML("")
        element.setInnerHTML('<span id="loading">Loading...</span>')
        
        unless blob.nil?
          set_html('hash', blob.id)
          last_commit_html(app, branch, file)
          
          if IMAGE_MIMES.include?(blob.mime_type)
            return display_as_image(blob, item)
          end
      
          blame = Grit::Blob.blame(app.repo, commit.id, file)
 
          blame_list = doc.createElement('ul')
          blame_list.setAttribute__('id', ELEMENTS[:list])
          blame_list.setInnerHTML('')
          i = 1
          blame.each do |commit, lines|
            lines.each do |line|
              line = line.empty? ? "&nbsp;" : line.escapeHTML
              li = doc.createElement('li')
              img = doc.createElement('img')
              url = gravatar_url(commit.author.email, 16, '').to_s
              img.setAttribute__('src', url)
              img.setAttribute__('class', 'gravatar')
              img.setAttribute__('title', commit.author.email)
              li.setInnerHTML(%(<span class="linenum">#{i}</span><span class="sha">#{commit.sha}</span><pre><code>#{line.chomp}</code></pre>))
              li.appendChild(img)
              blame_list.appendChild(li)
              i += 1
            end
          end
          element.setInnerHTML("")
          element.appendChild(blame_list)
        else 
          set_html('hash', 'Untracked or ignored file')
        end
      end
    end
  end
  
  def last_commit_html(app, branch, file)
    last_commit = app.repo.log(branch, file).last
    cdate = last_commit.authored_date.to_system_time
    set_html("date", "Last Modified: #{cdate} by #{last_commit.author.name}")
  end
  
  private
  
  def display_as_image(blob, outline_item)
    doc  = @main_view.mainFrame.DOMDocument
    wrap = doc.createElement('div')
    img  = doc.createElement('img')
    
    url  = NSURL.fileURLWithPath(outline_item.fullPath)
    img.setAttribute__('src', url.to_s)
    img.setAttribute__('class', 'inline-image')
    
    wrap.setAttribute__('class', 'image-wrapper')
    wrap.appendChild(img)
    
    doc.getElementById(ELEMENTS[:blame]).appendChild(wrap)
  end
  
  def render_last_commit_html(blob, branch)
    
  end
  
  def setup_web_view
    @main_view = WebView.alloc.init
    @main_view.setAutoresizingMask(NSViewWidthSizable|NSViewHeightSizable)
    @main_view.setFrameSize(@main_canvas.frame.size)
    @main_canvas.addSubview(@main_view)
    
    web_view = File.join(NSBundle.mainBundle.bundlePath, "Contents", "Resources", "blame.html")
    @main_view.mainFrame.loadRequest(NSURLRequest.requestWithURL(NSURL.fileURLWithPath(web_view)))
  end
  
  def set_html(element, html)
    @main_view.mainFrame.DOMDocument.getElementById(element).setInnerHTML(html)
  end
end
