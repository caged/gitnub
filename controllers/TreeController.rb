#
#  TreeController.rb
#  GitNub
#
#  Created by Justin Palmer on 9/30/08.
#  Copyright (c) 2008 ENTP <http://hoth.entp.com>. All rights reserved.
#

require 'osx/cocoa'
OSX.ns_import 'GNFileSystemItem'
OSX.ns_import 'GNTreeDataSource'


class TreeController < OSX::NSObject
  ib_outlet :tree_outline
  ib_outlet :file_canvas
  ib_outlet :tree_data_source
  
  def awakeFromNib
    @tree_outline.setDelegate(@tree_data_source)
    @tree_outline.expandItem(@tree_outline.itemAtRow(0))
  end
end
