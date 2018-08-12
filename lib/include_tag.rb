require "include_tag/version"

module IncludeTag
  class Expander
    attr_accessor :lines
    attr_accessor :dir, :base

    def initialize(file)
      @dir, @base = Pathname.new(file).split
      @lines = File.readlines(file)
    end

    def content
      @lines.join
    end

    def include_tag?(line)
      /^\[\[include:(.+)\]\]/.match?(line)
    end

    def convert_tag_to_path(line)
      @dir + line.gsub(/\[\[include:(.+)\]\]/,'\1.md').strip
    end

    def path_to_manifest
      @dir + @base
    end
  end
end
