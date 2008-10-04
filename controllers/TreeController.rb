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


class TreeController < OSX::NSObject
  ib_outlet :tree_outline
  ib_outlet :file_canvas
  ib_outlet :tree_data_source
  ib_outlet :main_canvas
  ib_outlet :main_webview
  
  def awakeFromNib
    dsource = GNTreeDataSource.alloc.init
    @tree_outline.setDataSource(dsource)
    @tree_outline.setDelegate(dsource)
    @tree_outline.expandItem(@tree_outline.itemAtRow(0))
  	NSNotificationCenter.defaultCenter.objc_send(:addObserver, self,
  		:selector, :item_was_selected,
  		:name, "NSOutlineViewSelectionDidChangeNotification",
  		:object, @tree_outline)
  		
  	Notify.on 'branch_was_changed' do |opts|
  	  puts "BRANCH WAS CHANGED"
	  end
  end
  
  def branch_was_changed(branch)
    puts "BRANCH WAS CHANGED"
  end
  
  def item_was_selected(notification)
    outline_view = notification.object
    item = outline_view.itemAtRow(outline_view.selectedRow)
    unless item.nil?
      puts NSApplication.sharedApplication.delegate.active_branch
      puts item.fullPath
    end
  end
end
