require "include_tag/version"
require "pathname"

module IncludeTag
  class Expander
    attr_accessor :lines
    attr_accessor :dir, :base
    attr_accessor :top_level

    def initialize(file)
      @dir, @base = Pathname.new(file).split
      @lines = File.readlines(file)
    end

    def content
      @lines.map do |line|
        process_each_line(line)
      end.flatten.join("\n")
    end

    def reset_headings(content)
      @top_level.to_s.empty? ? content : content.gsub(/(#+)/,"#{@top_level}"+'\1')
    end

    def process_each_line(line)
      # given a line, any line
      # test if setting top_level
      # yes:  set top_level destroy line
      # test if clearing top_level
      # yes:  set top_level = nil destroy line

      # test if line is an include_tag
      if match = include_tag?(line)
        convert_tag_to_content(line).split("\n").map{|ln| process_each_line(ln)}
      else 
        line
      end
      # flatten
    end



    def include_tag_pattern
      /^\[\[include:(.+)\]\]/
    end

    def include_tag?(line)
      include_tag_pattern.match(line)
    end

    def convert_tag_to_path(line)
      @dir + line.gsub(include_tag_pattern,'\1.md').strip
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
