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
libdir = OSX::NSBundle.mainBundle.resourcePath.stringByAppendingPathComponent("lib").fileSystemRepresentation
$:.unshift(libdir, "#{libdir}/grit/lib", "#{libdir}/mime-types/lib")
require 'grit'
require 'time_extensions'
require 'string_extensions'
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
  ib_outlet :local_branches_menu
  ib_outlet :remote_branches_menu
  ib_outlet :tags_menu
  ib_outlet :search_field
  
  def applicationDidFinishLaunching(sender)
    @window.makeKeyAndOrderFront(self)
  end
  
  def applicationShouldTerminateAfterLastWindowClosed(notification)
    return true
  end
  
  def awakeFromNib
    if repo
      @window.delegate = self
      column = @commits_table.tableColumns[0]
      cell = CommitSummaryCell.alloc.init
      column.dataCell = cell
    
      @main_view.setFrameSize(@main_canvas.frame.size)
      @main_canvas.addSubview(@main_view)    
    
      @branch_field.cell.setBackgroundStyle(NSBackgroundStyleRaised)
      
      setup_refs_view_menu
      setup_search_field
    end
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
  
  def set_search_category(sender)
    menu = @search_field.cell.searchMenuTemplate
    menu.itemWithTitle(@current_search_item).setState(NSOffState)
    menu.itemWithTitle(sender.title).setState(NSOnState)
    @search_field.cell.setSearchMenuTemplate(menu)
    @current_search_item = sender.title
  end
  
  private
    def setup_refs_view_menu
      [@local_branches_menu, @remote_branches_menu, @tags_menu].each { |m| m.submenu.setAutoenablesItems(false) }
      
      heads = repo.heads.sort_by do |head|
        head.name == 'master' ? "***" : head.name
      end
      
      add_menu_item = lambda do |refs, menu|
        refs.each_with_index do |head, index|
          item = NSMenuItem.alloc.initWithTitle_action_keyEquivalent(head.name, :swap_branch, index.to_s)
          item.setEnabled(true)
          item.setTarget(@commits_controller)
          menu.submenu.addItem(item)
        end
      end
      
      add_menu_item.call(heads, @local_branches_menu)
      add_menu_item.call(repo.remotes, @remote_branches_menu)
      add_menu_item.call(repo.tags, @tags_menu)
    end  
    
    def setup_search_field
      @search_menu = NSMenu.alloc.initWithTitle("Search Menu")
      @search_field.cell.setSearchMenuTemplate(@search_menu)
      @search_menu.setAutoenablesItems(false)
      
      add_menu_item = lambda do |title, tooltip, state|
        item = NSMenuItem.alloc.initWithTitle_action_keyEquivalent(title, :set_search_category, "")
        @search_menu.addItem(item)
        item.setToolTip(tooltip)
        item.setEnabled(true)
        item.setTarget(self)
        if state
          item.setState(NSOnState)
          @current_search_item =  title
        end
      end
      
      add_menu_item.call("Commits", "Search commit messages", true)
      add_menu_item.call("SHA1", "Find a commit by its SHA1 hash", false)
      add_menu_item.call("Author", "Find all all commits by a particular author", false)
      add_menu_item.call("Path", "Find commits based on a path", false)

    end
end
