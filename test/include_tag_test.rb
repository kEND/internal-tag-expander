require "test_helper"

class IncludeTagTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::IncludeTag::VERSION
  end

  def test_ask_returns_an_answer
    expander = IncludeTag::Expander.new
    assert expander.ask("whatever") != nil
  end
end
