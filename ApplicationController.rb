#
#  ApplicationController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/1/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'grit'

include OSX
OSX.ns_import 'ImageTextCell'

class ApplicationController < OSX::NSObject  
  ib_outlet :commits_table, :commits_controller
  def awakeFromNib
    column = @commits_table.tableColumns[0]
    cell = ImageTextCell.alloc.init
    column.dataCell = cell
    cell.dataDelegate = @commits_controller
  end
end
