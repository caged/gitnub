class GitNubWebView < WebView
  def awakeFromNib
    self.setUIDelegate(self)
    self.setPolicyDelegate(self)
  end
  
  def webView_dragDestinationActionMaskForDraggingInfo(view, info)
    WebDragDestinationActionLoad
  end
  
  def webView_dragSourceActionMaskForPoint(view, point)
    WebDragSourceActionLink
  end
  
  def performDragOperation(sender)
    # str = sender.draggingPasteboard.stringForType("NSStringPboardType")
    # puts NSURL.URLWithString(str).host
  end
  
  def webView_decidePolicyForNavigationAction_request_frame_decisionListener(webview, info, request, frame, listener)
    puts info['WebActionNavigationTypeKey']
    
    if info['WebActionNavigationTypeKey'].to_i == 0
      if request.URL.to_s =~ /^file:\/\//
        listener.use
      else
        listener.ignore
        NSWorkspace.sharedWorkspace.openURL(request.URL)
      end
    else 
      listener.use
    end
  end
end