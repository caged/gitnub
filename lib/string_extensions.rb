class String
  HTML_ESCAPES = {
    ?& => "amp",
    ?" => "quot",
    ?< => "lt",
    ?> => "gt"
  }.freeze

  def escapeHTML
    self.split("").collect { |x| HTML_ESCAPES.key?(x.ord) ? "&#{HTML_ESCAPES[x.ord]};" : x }.join("")
  end

  # Ruby 1.9 forward-compatibility
  unless String.method_defined?(:ord)
    define_method :ord do
      self[0]
    end
  end
end
