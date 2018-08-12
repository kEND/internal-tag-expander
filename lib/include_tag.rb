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
        include_tag?(line) ? convert_tag_to_content(line) : line.strip
      end.join
    end

    def include_tag?(line)
      /^\[\[include:(.+)\]\]/.match?(line)
    end

    def convert_tag_to_path(line)
      @dir + line.gsub(/\[\[include:(.+)\]\]/,'\1.md').strip
    end

    def convert_tag_to_content(line)
      File.read(convert_tag_to_path(line))
    end

    def path_to_manifest
      @dir + @base
    end
  end
end
