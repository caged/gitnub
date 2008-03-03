#
#  TexturedWindow.rb
#  GitNub
#
#  Created by Justin Palmer on 3/2/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'

class TexturedWindow < OSX::NSWindow
  def initWithContentRect_styleMask_backing_defer(rect, mask, backing, defer)
    if super_initWithContentRect_styleMask_backing_defer(rect, mask, backing, defer)
      self.setContentBorderThickness_forEdge(44.0, NSMinYEdge)
    end
    return self
  end
end
