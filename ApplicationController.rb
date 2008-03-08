#
#  ApplicationController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/1/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#
$VERBOSE = nil
require 'rubygems'
require 'osx/cocoa'
require 'mime-types/lib/mime/types'
require 'grit/lib/grit'
require 'InfoWindowController'

OSX.ns_import 'ImageTextCell'
include OSX

REPOSITORY_LOCATION = ENV['PWD'].nil? ? '' : ENV['PWD']

class ApplicationController < OSX::NSObject 
  ib_outlet :commits_table
  ib_outlet :commits_controller 
  ib_outlet :window
  ib_outlet :main_canvas
  ib_outlet :main_view
  ib_outlet :info_button
  
  def applicationDidFinishLaunching(sender)
    @window.makeKeyAndOrderFront(self)  
  end
  
  def applicationShouldTerminateAfterLastWindowClosed(notification)
    return true
  end
  
  def awakeFromNib    
    begin
      @repo = Grit::Repo.new(REPOSITORY_LOCATION)
    rescue Grit::InvalidGitRepositoryError
      return false
    end
    
    @window.delegate = self
    column = @commits_table.tableColumns[0]
    cell = ImageTextCell.alloc.init
    column.dataCell = cell
    cell.dataDelegate = @commits_controller
    
    @main_view.setFrameSize(@main_canvas.frame.size)
    @main_canvas.addSubview(@main_view)
  end
  
  ib_action :show_info_panel
  def show_info_panel(sender)
    if @info_controller.nil? 
      @info_controller = InfoWindowController.alloc.init_with_repository(@repo)
    end
    @info_controller.showWindow(self)
  end
end
