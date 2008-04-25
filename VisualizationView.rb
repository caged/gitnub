#
#  VisualizationView.rb
#  GitNub
#
#  Created by Justin Palmer on 4/12/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'
require 'ostruct'
require 'pp'

class VisualizationView <  OSX::NSView
  ib_outlet :application_controller
  
  def initWithFrame(frame)
    super_initWithFrame(frame)
    # Initialization code here.
    return self
  end
  
  def awakeFromNib
    @repo ||= @application_controller.repo
  end
  
  def isFlipped
    true
  end
  
  def drawRect(rect)
    nodes = {}
    context = NSGraphicsContext.currentContext
    NSColor.darkGrayColor.set
    NSRectFill(bounds)
    
    path = NSBezierPath.bezierPath
    path.lineWidth = 3

    path.moveToPoint([100, 105])
    path.appendBezierPathWithOvalInRect(NSMakeRect(100, 100, 10, 10))
    path.relativeMoveToPoint([0, 3.5])
    
    context.saveGraphicsState
    path.relativeLineToPoint([90, 0])
    context.restoreGraphicsState
    
    path.relativeMoveToPoint([5, 5])
    path.relativeCurveToPoint_controlPoint1_controlPoint2([40, 20], [0, 20], [-5, 20])
    
    path.appendBezierPathWithOvalInRect(NSMakeRect(200, 100, 10, 10))
    path.relativeMoveToPoint([0, 3.5])
    path.relativeLineToPoint([90, 0])
    path.appendBezierPathWithOvalInRect(NSMakeRect(300, 100, 10, 10))
    
    
    
    # commits = @repo.git.rev_list({:topo_order => true, :all => true, :pretty => 'raw', :full_history => true})
    # commits = Grit::Commit.list_from_string(@repo, commits)
    # commits.each_with_index do |commit, index|
    #   current_offset = 25 * (index + path_offset)
    #   path.moveToPoint([current_offset - ((path_offset * 25) + 40), 105])
    #   path.lineToPoint([current_offset, 105])
    #   path.appendBezierPathWithOvalInRect(NSMakeRect(current_offset, 100, 10, 10))
    #   commit.parents.each do |parent|
    #     npath = NSBezierPath.bezierPathWithOvalInRect(NSMakeRect((current_offset + 25), 125, 10, 10))
    #     NSColor.blueColor.set
    #     npath.fill
    #     npath.lineWidth = 3
    #     NSColor.whiteColor.set
    #     npath.stroke
    #     path_offset += 1
    #   end if commit.parents.size > 1
    # end
    
    NSColor.blackColor.set
    path.fill
    
    NSColor.whiteColor.set
    path.stroke
  end

end
