#
#  ApplicationController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/1/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'

class ApplicationController < OSX::NSObject
  ib_outlet :main_view
  def awakeFromNib
    NSLog(@main_view)
  end
end
