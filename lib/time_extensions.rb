class Time
  def to_system_time(style = :full)
    formatter = OSX::NSDateFormatter.alloc.init
    case style
      when :full
        formatter.dateStyle = OSX::NSDateFormatterMediumStyle
        formatter.timeStyle = OSX::NSDateFormatterShortStyle
      when :time
        formatter.dateStyle = OSX::NSDateFormatterNoStyle
        formatter.timeStyle = OSX::NSDateFormatterShortStyle
    end 
    formatter.stringFromDate(self.to_ns)
  end
end