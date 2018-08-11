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
end
