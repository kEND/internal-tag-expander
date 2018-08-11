require "include_tag/version"

module IncludeTag
  class Expander
    attr_accessor :lines
    def initialize(file)
      @lines = File.readlines(file)
    end
  end
end
