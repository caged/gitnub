#
#  ApplicationController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/1/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#
$VERBOSE = nil
require 'rubygems'
require 'pathname'
require 'osx/cocoa'
$: << "#{File.dirname(__FILE__)}/lib"
$: << "#{File.dirname(__FILE__)}/lib/grit/lib"
$: << "#{File.dirname(__FILE__)}/lib/mime-types/lib"
require 'grit'
require 'time_extensions'
require 'InfoWindowController'

OSX.ns_import 'CommitSummaryCell'
include OSX

# we use ENV['PWD'] instead of Dir.getwd if it exists so
# `open GitNub` will work, since that launches us at / but leaves ENV['PWD'] intact
pwd = Pathname.new(ENV['PWD'].nil? ? Dir.getwd : ENV['PWD'])
REPOSITORY_LOCATION = pwd + `cd #{pwd} && git rev-parse --git-dir 2>/dev/null`.chomp

class ApplicationController < OSX::NSObject 
  ib_outlet :commits_table
  ib_outlet :commits_controller 
  ib_outlet :window
  ib_outlet :main_canvas
  ib_outlet :main_view
  ib_outlet :branch_field
  ib_outlet :tab_panel
  ib_outlet :extras_segment
  
  def applicationDidFinishLaunching(sender)
    @window.makeKeyAndOrderFront(self)
  end
  
  def applicationShouldTerminateAfterLastWindowClosed(notification)
    return true
  end
  
  def awakeFromNib
    repo
    @window.delegate = self
    column = @commits_table.tableColumns[0]
    cell = CommitSummaryCell.alloc.init
    column.dataCell = cell
    
    @main_view.setFrameSize(@main_canvas.frame.size)
    @main_canvas.addSubview(@main_view)    
    
    @branch_field.cell.setBackgroundStyle(NSBackgroundStyleRaised)
  end
  
  def repo
    begin
      @repo ||= Grit::Repo.new(REPOSITORY_LOCATION)
    rescue Grit::InvalidGitRepositoryError
      return false
    end
  end
  
  ib_action :show_info_panel
  def show_info_panel(sender)
    @info_controller ||= InfoWindowController.alloc.init_with_repository(repo)
    @info_controller.showWindow(self)
  end
  
  ib_action :swap_tab
  def swap_tab(segment)
    tag = %w(commits network)[segment.cell.tagForSegment(segment.selectedSegment)]
    @tab_panel.selectTabViewItemWithIdentifier(tag)
  end
end
