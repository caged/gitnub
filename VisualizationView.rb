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
    points = []
    context = NSGraphicsContext.currentContext
    NSColor.darkGrayColor.set
    NSRectFill(self.bounds)
    
    path = NSBezierPath.bezierPath
    path.lineWidth = 2
    
    path.moveToPoint([100, 100])
    @repo.commits(:master, 50, 0).each_with_index do |commit, index|
      point = NSMakePoint(((index + 1) * 25), 100)
      path.lineToPoint([25 * index, 100])
      path.appendBezierPathWithOvalInRect(NSMakeRect(point[0] - 10, point[1], 10, 10))
    end
    
    NSColor.blackColor.set
    path.fill
    
    NSColor.whiteColor.set
    path.stroke
  end

end
