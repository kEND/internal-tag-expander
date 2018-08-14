require "test_helper"
require "pry"

class IncludeTagTest < Minitest::Test
  def setup
    path = Pathname.new(__dir__ + "/fixtures/manual/latex/")
    path.mkpath unless path.exist?
    path = path.realpath
    FileUtils.cd(path)
    @expander = IncludeTag::Expander.new("../../sample.md")
  end

  def test_expander_lines_should_return_array
    assert_instance_of Array, @expander.lines 
  end

  def test_expander_lines_should_return_real_lines_from_file
    assert_equal "[[include:manual/title]]\n", @expander.lines[0]
  end

  def test_include_tag_should_match_gollum_include_tags
    assert @expander.include_tag?("[[include:blah-blah]]\n")
    refute @expander.include_tag?("[[include[##]:blah-blah]]\n")
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
    assert_equal "baller/round.md", @expander.convert_tag_to_path("[[include:baller/round]]")
  end

  def test_expander_should_read_from_file_at_include_tag
    test_file_contents = File.read("../../manual/introduction.md")
    assert_equal test_file_contents, @expander.convert_tag_to_content("[[include:manual/introduction]]")
  end

  def test_expander_should_mark_a_tag_with_non_existent_file_when_attempting_to_convert_tag
    assert_equal "[[NO FILEinclude:manual/non-existent]]", @expander.convert_tag_to_content("[[include:manual/non-existent]]")
  end

  def test_should_reset_headings_returns_original_content_if_no_top_level
    assert_equal "## you are awesome", @expander.reset_headings("## you are awesome",nil)[0]
  end

  def test_should_reset_headings_if_top_level
    assert_equal "#### you are awesome", @expander.reset_headings("## you are awesome","##")[0]
  end

  def test_expander_content_should_match_target
    assert_equal File.read("../../manual.md"), @expander.content
  end

  def test_expander_title_body_should_combine
    test_file_contents = File.read("../../manual/title.md")
    test_file_contents += File.read("../../manual/introduction.md")
    out = @expander.convert_tag_to_content("[[include:manual/title]]")
    out += @expander.convert_tag_to_content("[[include:manual/introduction]]")
    assert_equal test_file_contents, out
  end

end
