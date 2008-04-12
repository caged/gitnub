#
#  VisualizationView.rb
#  GitNub
#
#  Created by Justin Palmer on 4/12/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'

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
    NSColor.darkGrayColor.set
    NSRectFill(self.bounds)
    
    path = NSBezierPath.bezierPath
    path.lineWidth = 2
    
    path.moveToPoint([100, 100])
    @repo.commits.each_with_index do |commit, index|
      index += 1
      path.lineToPoint([index * 25, 100])
      npath = NSBezierPath.bezierPathWithOvalInRect(NSMakeRect(index * 25, 97.5, 5, 5))
      npath.lineWidth = 4
      NSColor.whiteColor.set
      npath.stroke
      NSColor.blackColor.set
      npath.fill
    end

    
    NSColor.whiteColor.set
    path.stroke
  end

end
