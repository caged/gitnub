#
#  ImageLoadOperation.rb
#  gitnub
#
#  Created by Kevin Ballard on 3/21/08.
#  Copyright (c) 2008 Kevin Ballard. All rights reserved.
#

require 'osx/cocoa'

class ImageLoadOperation < OSX::NSOperation
  def initWithURL_delegate(url, delegate)
    init
    
    @url = url
    @delegate = delegate
    @executing = false
    @finished = false
    self
  end
  
  def isConcurrent
    true
  end
  
  def start
    request = NSURLRequest.requestWithURL(@url)
    @connection = NSURLConnection.connectionWithRequest_delegate(request, self)
    setExecuting true
  end
  
  def cancel
    super
    @connection.cancel
    setExecuting false
  end
  
  def isExecuting
    @executing
  end
  
  def isFinished
    @finished
  end
  
  # NSURLConnection Delegate methods
  def connection_didFailWithError(connection, error)
    @delegate.imageLoadForURL_didFailWithError(@url, error)
    setExecuting false
    setFinished true
  end
  
  def connection_didReceiveResponse(connection, response)
    length = response.expectedContentLength
    @data = NSMutableData.dataWithCapacity(length < 0 ? 0 : length)
  end
  
  def connection_didReceiveData(connection, data)
    @data.appendData(data)
  end
  
  def connectionDidFinishLoading(connection)
    image = NSImage.alloc.initWithData(@data)
    if image
      @delegate.imageLoadForURL_didFinishLoading(@url, image)
    else
      error = NSError.errorWithDomain_code_userInfo_(
        "GitNub", 0, {NSLocalizedDescriptionKey => "Could not recognize image data"}
      )
      @delegate.imageLoadForURL_didFailWithError(@url, error)
    end
    setExecuting false
    setFinished true
  end
  
  private
  
  def setExecuting(bool)
    self.willChangeValueForKey("isExecuting")
    @executing = bool
    self.didChangeValueForKey("isExecuting")
  end
  
  def setFinished(bool)
    self.willChangeValueForKey("isFinished")
    @finished = bool
    self.didChangeValueForKey("isFinished")
  end
end
