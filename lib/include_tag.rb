require "include_tag/version"
require "pathname"

module IncludeTag
  class Expander
    attr_accessor :lines
    attr_reader   :outlines
    attr_accessor :dir, :base, :include_dir
    attr_accessor :top_level

    def initialize(file)
      @dir, @base = Pathname.new(file).split
      @dir = @dir.realpath
      @lines = File.readlines(file)
      @top_level = @include_dir = nil
    end

    def content
      prepare_outlines
      @outlines.map{|i| i[0]}.join
    end

    def prepare_outlines
      @outlines = @lines.map {|line| [line, nil] }
      @outlines.map!    {|line, top_level| process_next_nest(line) }
      @outlines.map!    {|line, top_level| process_clear_top_level(line, top_level) }
      @outlines.reject! {|line, top_level| line.nil? }

      while @outlines.any? {|line, top_level| include_tag?(line) }
        @outlines.map!    {|line, top_level| process_include_tag(line, top_level) }
        @outlines.map!    {|a| inject_top_level(a) }
        @outlines = @outlines.flatten.each_slice(2).to_a
      end
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
        content = convert_tag_to_content(line).split(/^/)
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
      line.gsub(include_tag_pattern,'\1.md').strip
    end

    def convert_tag_to_content(line)
      relative_path = convert_tag_to_path(line)
      path = @dir + relative_path
      if @include_dir
        path = @include_dir.parent + relative_path unless path.exist?
        path = @include_dir + relative_path unless path.exist?
      end

      if path.exist?
        @include_dir, base = path.split
        File.read(path)
      else
        line.gsub("[[include","[[NO FILEinclude")
      end
    end

  end
end
