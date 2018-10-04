require "test_helper"
require "pry"

class IncludeTagTest < Minitest::Test
  def setup
    path = Pathname.new(__dir__ + "/fixtures/handbook/policy-manual/latex/")
    path.mkpath unless path.exist?
    path = path.realpath
    FileUtils.cd(path)
    @expander = IncludeTag::Expander.new("../../policy-manual-trimmed.md")
  end

  def test_expander_content_should_match_target
    assert_equal File.read("../../expected.md"), @expander.content
  end

  def test_expander_should_resolve_root_relative_tags
    assert_equal "/operational-policies/other.md", @expander.convert_tag_to_path("[[include:/operational-policies/other]]")
  end

  def test_expander_should_resolve_content_from_root_relative_tags
    test_file_contents = File.read("../../operational-policies/other.md")
    assert_equal test_file_contents, @expander.convert_tag_to_content("[[include:/operational-policies/other]]")
  end

end
