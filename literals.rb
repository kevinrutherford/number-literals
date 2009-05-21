require 'test/unit'

module Literals
  Ints = {:one => 1, :two => 2, :three => 3, :four => 4, :five => 5,
      :six => 6, :seven => 7, :eight => 8, :nine => 9}
  Ten = { :ten => 10 }
  Teens = {:eleven => 11, :twelve => 12, :thirteen => 13,
      :fourteen => 14, :fifteen => 15, :sixteen => 16,
      :seventeen => 17, :eighteen => 18, :nineteen => 19 }
  Tens = {:twenty => 20, :thirty => 30, :forty => 40,
      :fifty => 50, :sixty => 60, :seventy => 70,
      :eighty => 80, :ninety => 90 }

  class PartialValue
    def initialize(val) @value = val end
  end

  class NumericLiteral < PartialValue
    include Comparable

    attr_reader :value

    def <=>(other); @value <=> other.to_i; end
    def to_i; @value; end

    def thousand; Hundred.new(@value * 1000); end
  end

  class Numty < NumericLiteral
    Ints.each do |s,v|
      define_method(s) { Unit.new(@value + v) }
    end
  end

  class Unit < NumericLiteral
    def hundred() Hundred.new(@value * 100) end
  end
  
  class Hundred < NumericLiteral
    def and() Adder.new(@value) end

    (Ints.merge(Teens)).each do |s,v|
      define_method(s) { HundredExpecter.new(value + (v*100)) }
    end
  end
  
  class Adder < PartialValue
    (Ints.merge(Ten).merge(Teens)).each do |s,v|
      define_method(s) { Unit.new(@value + v) }
    end

    Tens.each do |s,v|
      define_method(s) { Numty.new(@value + v) }
    end
  end
  
  class HundredExpecter < PartialValue
    def hundred() Hundred.new(@value) end
  end

  (Ints.merge(Teens)).each do |s,v|
    define_method(s) { Unit.new(v) }
  end

  def ten; NumericLiteral.new(10); end

  Tens.each do |s,v|
    define_method(s) { Numty.new(v) }
  end
  
end

class LiteralsTester < Test::Unit::TestCase
  include Literals

  def test_numeric_literals
    assert_equal(3, three.to_i)
    assert_equal(10, ten)
    assert_equal(17, seventeen.to_i)
    assert_equal(40, forty.to_i)
    assert_equal(90, ninety.to_i)
  end

  def test_upto_one_hundred
    assert_raise(NoMethodError) { eleven.one }
    assert_equal(23, twenty.three.to_i)
    assert_equal(79, seventy.nine.to_i)
    assert_raise(NoMethodError) { sixty.forty }
    assert_raise(NoMethodError) { seven.fifty }
  end
  
  def test_hundreds
    assert_raise(NameError) { hundred }
    assert_equal(200, two.hundred)
    assert_equal(1300, thirteen.hundred)
    assert_raise(NoMethodError) { ten.hundred }
    assert_raise(NoMethodError) { twenty.hundred }
    assert_equal(2100, twenty.one.hundred)
    assert_raise(NoMethodError) { forty.hundred }
    assert_raise(NoMethodError) { two.hundred.hundred }
  end
  
  def test_hundreds_and_some
    assert_equal(104, one.hundred.and.four.to_i)
    assert(409 != four.hundred.nine)
    assert_equal(910, nine.hundred.and.ten)
    assert_equal(581, five.hundred.and.eighty.one.to_i)
    assert_raise(NoMethodError) { seventeen.hundred.and.hundred }
    assert_equal(4772, forty.seven.hundred.and.seventy.two)
  end
  
  def test_thousands
    assert_equal(4000, four.thousand)
    assert_equal(10000, ten.thousand)
    assert_equal(90000, ninety.thousand)
    assert_equal(46000, forty.six.thousand)
    assert_raise(NoMethodError) { one.hundred.and.thousand }
    assert_equal(700000, seven.hundred.thousand)
  end
  
  def test_thousands_and_some
    assert_equal(12006, twelve.thousand.and.six)
    assert(11013 != eleven.thousand.thirteen)
    assert_equal(17060, seventeen.thousand.and.sixty)
    assert_equal(52007, fifty.two.thousand.and.seven)
    assert_equal(88101, eighty.eight.thousand.one.hundred.and.one)
    assert_equal(123456, one.hundred.and.twenty.three.thousand.four.hundred.and.fifty.six)
  end

end
