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

end
