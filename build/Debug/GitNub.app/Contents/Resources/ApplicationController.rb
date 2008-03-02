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
require 'erubis'

include OSX

class ApplicationController < OSX::NSObject
  ib_outlet :main_view
  attr_reader :repo
  def awakeFromNib
    @repo = Grit::Repo.new("/Users/Caged/dev/clients/digisynd/code/client.rails")
    render 'log', {:repo => @repo, :branches => @repo.branches }
  end
  
  def render(file, context)
    log_template = File.join(NSBundle.mainBundle.bundlePath, "Contents", "Resources", "#{file}.html.erb")
    eruby = Erubis::FastEruby.load_file(log_template)
    @main_view.mainFrame.loadHTMLString_baseURL(eruby.evaluate(context), NSURL.fileURLWithPath(File.join(NSBundle.mainBundle.bundlePath, "Contents", "Resources")))
  end
end
