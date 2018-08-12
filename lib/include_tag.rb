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
      @lines.map do |line|
        [content_and_top_level_from(line)]
      end.map {|content, top_level| content}.join
    end

    def content_and_top_level_from(line)
      if match = include_tag?(line)
        content, top_level = convert_tag_to_content(line), match[1]
      else
        content, top_level = line.strip, ""
      end
    end

    def include_tag_pattern
      /^\[\[include\[?(#*)\]?:(.+)\]\]/
    end

    def include_tag?(line)
      include_tag_pattern.match(line)
    end

    def convert_tag_to_path(line)
      @dir + line.gsub(include_tag_pattern,'\2.md').strip
    end

    def convert_tag_to_content(line)
      path = convert_tag_to_path(line)
      path.exist? ? File.read(path) : line.strip + 'NO FILE'
    end

    def path_to_manifest
      @dir + @base
    end
  end
end
