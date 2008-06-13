# Yanked from http://github.com/evanphx/osx-notify/tree/master
module OSX
  class Notify < OSX::NSObject
 
    @@notifications = []
 
    def self.on(name, &block)
      notify = new()
 
      @@notifications << notify
 
      notify.name = name
      notify.block = block
 
      c = OSX::NSDistributedNotificationCenter.defaultCenter
      c.addObserver_selector_name_object_ notify, "call:", name, nil
      return notify
    end
 
    def self.send(name, opts)
      c = OSX::NSDistributedNotificationCenter.defaultCenter
      c.postNotificationName_object_userInfo_deliverImmediately_ name, nil, opts, true
    end
 
    attr_accessor :block, :name
 
    def call(notification)
      @block.call(notification.userInfo)
    end
 
    def delete!
      c = OSX::NSDistributedNotificationCenter.defaultCenter
      c.removeObserver_name_object_ self, @name, nil
      @@notifications.delete self
    end
  end
end