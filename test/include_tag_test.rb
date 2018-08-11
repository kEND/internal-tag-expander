require "test_helper"

class IncludeTagTest < Minitest::Test
  def setup
    @expander = IncludeTag::Expander.new("test/fixtures/sample.md")
  end

  def test_expander_lines_should_return_array
    assert_instance_of Array, @expander.lines 
  end

  def test_expander_lines_should_return_real_lines_from_file
    assert_equal "[[include:manual/title]]\n", @expander.lines[0]
  end

  def test_include_tag_should_match_gollum_include_tags
    assert @expander.include_tag?("[[include:blah-blah]]\n")
  end

  def test_include_tag_should_not_match_other_lines
    refute @expander.include_tag?("### my doggie\n")
  end

  def test_expander_should_detect_include_tag
    assert @expander.include_tag?(@expander.lines[0])
  end

  def test_expander_should_detect_non_include_tag
    refute @expander.include_tag?(@expander.lines[3])
  end

  def test_expander_should_build_viable_path_when_processing_an_include_tag
    assert_equal "text/fixtures/baller/round.md", @expander.path_to_file("[[include:baller/round]]\n")
  end

  def test_expander_content_should_match_target
    skip
    assert_equal File.read("test/fixtures/manual.md"), @expander.content
  end
end
