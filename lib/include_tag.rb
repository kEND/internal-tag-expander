require "include_tag/version"

module IncludeTag
  class Expander
    attr_accessor :lines
    def initialize(file)
      @lines = File.readlines(file)
    end

    def content
      @lines.join
    end

    def include_tag?(line)
      /^\[\[include:(.+)\]\]/.match?(line)
    end
  end
end
