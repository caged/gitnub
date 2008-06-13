#
#  NetworkController.rb
#  GitNub
#
#  Created by Justin Palmer on 6/5/08.
#  Copyright (c) 2008 Active Reload, LLC. All rights reserved.
#

require 'osx/cocoa'

class NetworkController < OSX::NSObject
  ib_outlet :application_controller
  ib_outlet :network_view
  
  def awakeFromNib
    if @application_controller.repo
      @github_user = @application_controller.repo.config['github.user']
      @github_repo = @application_controller.repo.config['github.repo']
      setup_network_visualization_view
    end
  end
  
  def has_github_credentials?
     @github_user && @github_repo
  end
  
  def setup_network_visualization_view
    github_network_url = NSURL.URLWithString("http://github.com/#{@github_user}/#{@github_repo}/network")
    @network_view.setFrameLoadDelegate(self)
    if has_github_credentials?
      @network_view.mainFrame.loadRequest(NSURLRequest.requestWithURL(github_network_url))
    else
      @network_view.mainFrame.loadHTMLString_baseURL(%(
        <html>
        <head>
          <style type="text/css">
            body {
              font: normal 12px/1.5em "Helvetica Neue", Helvetica, Arial, sans-serif;
              color:#333;
            }
          </style>
        </head>
        <body style="padding:30px">
          <h2>If this is a Github repository you can set your credentials to view your network</h2>
          <pre>
            git config github.user  REPO_USER
            git config githubV.repo REPO_NAME
          </pre>
        </body>
        </html>
      ), nil)
    end
  end

  def webView_didFinishLoadForFrame(view, frame)
    @document = @network_view.mainFrame.DOMDocument
    setup_document if has_github_credentials?
  end
  
  def setup_document
    unless @github_user.nil? || @github_repo.nil?
      hide_github_shell
      setup_network_viewer
      replace_github_header
    end
  end
  
  def setup_network_viewer
    network = @document.getElementById('network')
    network.setAttribute_value('style', "margin-top:60px")
    h2 = @document.getElementsByTagName('h2').item(0)
    p1 = @document.getElementById('network').children.item(1)
    p2 = @document.getElementById('network').children.item(2)
    
    [h2, p1, p2].each do |element|
      element.style.setProperty_value_priority("display", "none", nil)
    end
  end
  
  def replace_github_header
    header = @document.createElement('div')
    old_header = @document.getElementById('header')
  
    style = %(
      font-size: 150%;
      line-height: 130%;
      color: #222;
      text-align:left;
      padding:9px;
      font-family:"Helvetica Neue" !important;
      font-weight:bold;
      border-bottom:1px solid #ccc;
    )
  
    header.setAttribute_value('style', style)
    header.setInnerHTML(%(Github Network))
    old_header.parentNode.insertBefore_refChild(header, old_header)
  end
  
  # Because we're only interested in the network visualizer
  def hide_github_shell
    %w(header repo_menu repo_sub_menu repos footer triangle).each do |element|
      element = @document.getElementById(element)
      element.style.setProperty_value_priority("display", "none", nil)
    end
  end
end
