#
#  InfoWindowController.rb
#  GitNub
#
#  Created by Justin Palmer on 3/6/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'

class InfoWindowController < OSX::NSWindowController
  ib_outlet :push_url
  ib_outlet :clone_url
  ib_outlet :commits_count
  
  def init_with_repository(repository)
    @repo = repository
    initWithWindowNibName("Info")
    return self
  end
  
  def awakeFromNib
    clone_url = @repo.git.config({}, "--get", "remote.origin.url").gsub("\n", '')
    @clone_url.stringValue = clone_url
    
    @commits_count.stringValue = @repo.commit_count
  end
end
