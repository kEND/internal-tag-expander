require "include_tag/version"
require "pathname"

module IncludeTag
  class Expander
    attr_accessor :lines
    attr_reader   :outlines
    attr_accessor :dir, :base
    attr_accessor :top_level

    def initialize(file)
      @dir, @base = Pathname.new(file).split
      @lines = File.readlines(file)
    end

    def content
      prepare_outlines
      @outlines.map{|i| i[0]}.join("\n")
    end

    def prepare_outlines
      @outlines = @lines.map {|line| [line, nil] }
      @outlines.map!    {|line, top_level| process_next_nest(line) }
      @outlines.map!    {|line, top_level| process_clear_top_level(line, top_level) }
      @outlines.reject! {|line, top_level| line.nil? }
      @outlines.map!    {|line, top_level| process_include_tag(line, top_level) }
      @outlines.map!    {|a| inject_top_level(a) }
      @outlines = @outlines.flatten.each_slice(2).to_a
    end

    def inject_top_level(a)
      if a[0].is_a? Array  
        entry = a[0].map {|i| [i,a[1]]}    
      else  
        entry = a
      end  
      entry
    end

    def reset_headings(content, top_level)
      result = content
      unless top_level.to_s.empty?
        if content.is_a? String
          result = content.gsub(/(#+)/,"#{top_level}"+'\1')
        elsif content.is_a? Array
          result = content.map{|line| line.gsub(/(#+)/,"#{top_level}"+'\1')}
        else
          result = content
        end
      end
      [result, top_level]
    end

    def process_next_nest(line)
      top_level = @top_level
      if match = next_nest_tag?(line)
        @top_level = match[1]
        line = nil
      end
      [line, top_level]
    end

    def process_clear_top_level(line, top_level)
      if clear_top_level_tag?(line)
        top_level = @top_level = nil
        line = nil
      end
      [line, top_level]
    end

    def process_include_tag(line, top_level)
      if match = include_tag?(line)
        content = convert_tag_to_content(line).split("\n") # .map{|ln| process_each_line(ln)}.join("\n")
        reset_headings(content, top_level)
      else
        [line, top_level]
      end
    end

    def process_each_line(line)
      # given a line, any line
      # test if setting top_level
      line = process_next_nest(line)
      # test if clearing top_level
      line = process_clear_top_level(line)
      # yes:  set top_level = nil destroy line
      # test if line is an include_tag
      process_include_tag(line)
    end

    def next_nest_tag?(line)
      /^\[\/\/\]:\s+nest_next_(#+)/.match(line)
    end

    def clear_top_level_tag?(line)
      line =~ /^\[\/\/\]:\s+clear_top_level/
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
      path.exist? ? File.read(path) : line.strip + 'NO FILE\n'
    end

    def path_to_manifest
      @dir + @base
    end
  end
end
