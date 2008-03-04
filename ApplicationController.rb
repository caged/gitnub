#
#  ApplicationController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/1/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'rubygems'
require 'osx/cocoa'
require 'grit'

include OSX
OSX.ns_import 'ImageTextCell'

class ApplicationController < OSX::NSObject  
  ib_outlet :commits_table, :commits_controller, :window
  
  def applicationDidFinishLaunching(sender)
    @window.makeKeyAndOrderFront(self)  
  end
  
  def applicationShouldTerminateAfterLastWindowClosed(notification)
    return true
  end
  
  def awakeFromNib
    @window.delegate = self
    column = @commits_table.tableColumns[0]
    cell = ImageTextCell.alloc.init
    column.dataCell = cell
    cell.dataDelegate = @commits_controller
  end
end
