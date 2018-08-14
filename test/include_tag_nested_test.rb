require "test_helper"
require "pry"

class IncludeTagTest < Minitest::Test
  def setup
    path = Pathname.new(__dir__ + "/fixtures/manual/latex/")
    path.mkpath unless path.exist?
    path = path.realpath
    FileUtils.cd(path)
    @expander = IncludeTag::Expander.new("../../sample-nested.md")
  end

  def test_expander_content_should_match_target
    assert_equal File.read("../../manual-nested.md"), @expander.content
  end

  def test_if_outlines_contains_any_unresolved_include_tags
    outlines = @expander.lines.map {|line| [line, nil] }
    assert outlines.any? {|line, top_level| @expander.include_tag?(line) }
  end
end
