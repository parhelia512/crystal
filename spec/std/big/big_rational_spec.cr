require "spec"
require "big"

private def br(n, d)
  BigRational.new(n, d)
end

private def test_greater(val, other, *, file = __FILE__, line = __LINE__)
  val.should be > other, file: file, line: line
  other.should_not be > val, file: file, line: line
  (val <=> other).should_not(be_nil).should be > 0, file: file, line: line
  (other <=> val).should_not(be_nil).should be < 0, file: file, line: line
end

private def test_equal(val, other, *, file = __FILE__, line = __LINE__)
  (val == other).should be_true, file: file, line: line
  (other == val).should be_true, file: file, line: line
  (val <=> other).should eq(0), file: file, line: line
  (other <=> val).should eq(0), file: file, line: line
end

private def test_less(val, other, *, file = __FILE__, line = __LINE__)
  val.should be < other, file: file, line: line
  other.should_not be < val, file: file, line: line
  (val <=> other).should_not(be_nil).should be < 0, file: file, line: line
  (other <=> val).should_not(be_nil).should be > 0, file: file, line: line
end

private def test_comp(val, less, equal, greater, *, file = __FILE__, line = __LINE__)
  test_greater(val, less, file: file, line: line)
  test_equal(val, equal, file: file, line: line)
  test_less(val, greater, file: file, line: line)
end

describe BigRational do
  describe ".new" do
    it "initialize" do
      BigRational.new(BigInt.new(10), BigInt.new(3))
        .should eq(BigRational.new(10, 3))

      expect_raises(DivisionByZeroError) do
        BigRational.new(BigInt.new(2), BigInt.new(0))
      end

      expect_raises(DivisionByZeroError) do
        BigRational.new(2, 0)
      end
    end

    it "initializes from BigFloat with high precision" do
      (0..12).each do |i|
        bf = BigFloat.new(2.0, precision: 64) ** 64 + BigFloat.new(2.0, precision: 64) ** i
        br = BigRational.new(bf)
        br.should eq(bf)
      end
    end

    it "raises if creating from infinity" do
      expect_raises(ArgumentError, "Can only construct from a finite number") { BigRational.new(Float32::INFINITY) }
      expect_raises(ArgumentError, "Can only construct from a finite number") { BigRational.new(Float64::INFINITY) }
    end

    it "raises if creating from NaN" do
      expect_raises(ArgumentError, "Can only construct from a finite number") { BigRational.new(Float32::NAN) }
      expect_raises(ArgumentError, "Can only construct from a finite number") { BigRational.new(Float64::NAN) }
    end
  end

  it "#numerator" do
    br(10, 3).numerator.should eq(BigInt.new(10))
  end

  it "#denominator" do
    br(10, 3).denominator.should eq(BigInt.new(3))
  end

  it "#to_s" do
    br(10, 3).to_s.should eq("10/3")
    br(90, 3).to_s.should eq("30")
    br(1, 98).to_s.should eq("1/98")

    r = BigRational.new(8243243, 562828882)
    r.to_s(16).should eq("7dc82b/218c1652")
    r.to_s(36).should eq("4woiz/9b3djm")
  end

  it "#to_i" do
    br(10, 3).to_i.should eq(3)
    br(90, 3).to_i.should eq(30)
    br(1, 98).to_i.should eq(0)
    br(-10, 3).to_i.should eq(-3)
    expect_raises(OverflowError) { br(Int64::MAX, 1).to_i }
  end

  it "#to_f64" do
    r = br(10, 3)
    f = 10.to_f64 / 3.to_f64
    r.to_f64.should be_close(f, 0.001)
  end

  it "#to_f64!" do
    r = br(10, 3)
    f = 10.to_f64 / 3.to_f64
    r.to_f64!.should be_close(f, 0.001)
  end

  it "#to_f" do
    r = br(10, 3)
    f = 10.to_f64 / 3.to_f64
    r.to_f.should be_close(f, 0.001)
  end

  it "#to_f!" do
    r = br(10, 3)
    f = 10.to_f64 / 3.to_f64
    r.to_f!.should be_close(f, 0.001)
  end

  it "#to_f32" do
    r = br(10, 3)
    f = 10.to_f32 / 3.to_f32
    r.to_f32.should be_close(f, 0.001)
  end

  it "#to_f32!" do
    r = br(10, 3)
    f = 10.to_f32 / 3.to_f32
    r.to_f32!.should be_close(f, 0.001)
  end

  it "#to_big_f" do
    r = br(10, 3)
    f = 10.to_big_f / 3.to_big_f
    r.to_big_f.should be_close(f, 0.001)
  end

  it "#to_big_r" do
    r = br(10, 3)
    r.to_big_r.should eq(r)
  end

  it "Int#to_big_r" do
    3.to_big_r.should eq(br(3, 1))
  end

  it "Float32#to_big_r" do
    0.3333333333333333333333_f32.to_big_r.should eq(br(11184811, 33554432))
  end

  it "Float64#to_big_r" do
    0.3333333333333333333333_f64.to_big_r.should eq(br(6004799503160661, 18014398509481984))
  end

  it "BigDecimal#to_big_r" do
    BigDecimal.new("1.123").to_big_r.should eq(br(1123, 1000))
  end

  describe "#<=>" do
    it "BigRational and Comparable" do
      a = br(11, 3)
      l = br(10, 3)
      e = a
      g = br(12, 3)

      # verify things aren't swapped
      [l, e, g].each { |o| (a <=> o).should eq(a.to_f <=> o.to_f) }

      test_comp(a, l, e, g)
    end

    it "Int and Comparable" do
      test_comp(br(10, 2), 4_i32, 5_i32, 6_i32)
      test_comp(br(10, 2), 4_i64, 5_i64, 6_i64)
    end

    it "BigInt and Comparable" do
      test_comp(br(10, 2), BigInt.new(4), BigInt.new(5), BigInt.new(6))
    end

    it "Float and Comparable" do
      test_comp(br(10, 2), 4.0_f32, 5.0_f32, 6.0_f32)
      test_comp(br(10, 2), 4.0_f64, 5.0_f64, 6.0_f64)
    end

    it "BigFloat and Comparable" do
      test_greater(1.to_big_r + 0.5.to_big_r ** (BigFloat.default_precision + 66), 1.to_big_f)
      test_less(1.to_big_r - 0.5.to_big_r ** (BigFloat.default_precision + 66), 1.to_big_f)
    end

    it "compares against NaNs" do
      (1.to_big_r <=> Float64::NAN).should be_nil
      (1.to_big_r <=> Float32::NAN).should be_nil
      (Float64::NAN <=> 1.to_big_r).should be_nil
      (Float32::NAN <=> 1.to_big_r).should be_nil

      typeof(1.to_big_r <=> Float64::NAN).should eq(Int32?)
      typeof(1.to_big_r <=> Float32::NAN).should eq(Int32?)
      typeof(Float64::NAN <=> 1.to_big_r).should eq(Int32?)
      typeof(Float32::NAN <=> 1.to_big_r).should eq(Int32?)

      typeof(1.to_big_r <=> 1.to_big_f).should eq(Int32)
    end
  end

  it "#+" do
    (br(10, 7) + br(3, 7)).should eq(br(13, 7))
    (0 + br(10, 7) + 3).should eq(br(31, 7))
  end

  it "#-" do
    (br(10, 7) - br(3, 7)).should eq(br(7, 7))
    (br(10, 7) - 3).should eq(br(-11, 7))
    (0 - br(10, 7)).should eq(br(-10, 7))
  end

  it "#*" do
    (br(10, 7) * br(3, 7)).should eq(br(30, 49))
    (1 * br(10, 7) * 3).should eq(br(30, 7))
  end

  it "#/" do
    (br(10, 7) / br(3, 7)).should eq(br(10, 3))
    expect_raises(DivisionByZeroError) { br(10, 7) / br(0, 10) }
    (br(10, 7) / 3).should eq(br(10, 21))
    (1 / br(10, 7)).should eq(br(7, 10))
  end

  it "#//" do
    (br(18, 7) // br(4, 5)).should eq(br(3, 1))
    (br(-18, 7) // br(4, 5)).should eq(br(-4, 1))
    (br(18, 7) // br(-4, 5)).should eq(br(-4, 1))
    (br(-18, 7) // br(-4, 5)).should eq(br(3, 1))

    (br(18, 5) // 2).should eq(br(1, 1))
    (br(-18, 5) // 2).should eq(br(-2, 1))
    (br(18, 5) // -2).should eq(br(-2, 1))
    (br(-18, 5) // -2).should eq(br(1, 1))
    (br(18, 5) // 2.to_big_i).should eq(br(1, 1))

    expect_raises(DivisionByZeroError) { br(18, 7) // br(0, 1) }
    expect_raises(DivisionByZeroError) { br(18, 7) // 0 }

    (8 // br(10, 7)).should eq(5)
    (-8 // br(10, 7)).should eq(-6)
    (8 // br(-10, 7)).should eq(-6)
    (-8 // br(-10, 7)).should eq(5)

    expect_raises(DivisionByZeroError) { 8 // br(0, 7) }
  end

  it "#%" do
    (br(18, 7) % br(4, 5)).should eq(br(6, 35))
    (br(-18, 7) % br(4, 5)).should eq(br(22, 35))
    (br(18, 7) % br(-4, 5)).should eq(br(-22, 35))
    (br(-18, 7) % br(-4, 5)).should eq(br(-6, 35))

    (br(18, 5) % 2).should eq(br(8, 5))
    (br(-18, 5) % 2).should eq(br(2, 5))
    (br(18, 5) % -2).should eq(br(-2, 5))
    (br(-18, 5) % -2).should eq(br(-8, 5))
    (br(18, 5) % 2.to_big_i).should eq(br(8, 5))

    expect_raises(DivisionByZeroError) { br(18, 7) % br(0, 1) }
    expect_raises(DivisionByZeroError) { br(18, 7) % 0 }
  end

  it "#tdiv" do
    br(18, 7).tdiv(br(4, 5)).should eq(br(3, 1))
    br(-18, 7).tdiv(br(4, 5)).should eq(br(-3, 1))
    br(18, 7).tdiv(br(-4, 5)).should eq(br(-3, 1))
    br(-18, 7).tdiv(br(-4, 5)).should eq(br(3, 1))

    br(18, 5).tdiv(2).should eq(br(1, 1))
    br(-18, 5).tdiv(2).should eq(br(-1, 1))
    br(18, 5).tdiv(-2).should eq(br(-1, 1))
    br(-18, 5).tdiv(-2).should eq(br(1, 1))
    br(18, 5).tdiv(2.to_big_i).should eq(br(1, 1))

    expect_raises(DivisionByZeroError) { br(18, 7).tdiv(br(0, 1)) }
    expect_raises(DivisionByZeroError) { br(18, 7).tdiv(0) }
  end

  it "#remainder" do
    br(18, 7).remainder(br(4, 5)).should eq(br(6, 35))
    br(-18, 7).remainder(br(4, 5)).should eq(br(-6, 35))
    br(18, 7).remainder(br(-4, 5)).should eq(br(6, 35))
    br(-18, 7).remainder(br(-4, 5)).should eq(br(-6, 35))

    br(18, 5).remainder(2).should eq(br(8, 5))
    br(-18, 5).remainder(2).should eq(br(-8, 5))
    br(18, 5).remainder(-2).should eq(br(8, 5))
    br(-18, 5).remainder(-2).should eq(br(-8, 5))
    br(18, 5).remainder(2.to_big_i).should eq(br(8, 5))

    expect_raises(DivisionByZeroError) { br(18, 7).remainder(br(0, 1)) }
    expect_raises(DivisionByZeroError) { br(18, 7).remainder(0) }
  end

  it "#- (negation)" do
    (-br(10, 3)).should eq(br(-10, 3))
  end

  it "#inv" do
    (br(10, 3).inv).should eq(br(3, 10))
    expect_raises(DivisionByZeroError) { br(0, 3).inv }
  end

  it "#abs" do
    (br(-10, 3).abs).should eq(br(10, 3))
  end

  it "#<<" do
    (br(10, 3) << 2).should eq(br(40, 3))
  end

  it "#>>" do
    (br(10, 3) >> 2).should eq(br(5, 6))
  end

  describe "#**" do
    it "exponentiates with positive powers" do
      result = br(17, 11) ** 5
      result.should be_a(BigRational)
      result.should eq(br(1419857, 161051))

      result = br(17, 11) ** 5_u8
      result.should be_a(BigRational)
      result.should eq(br(1419857, 161051))
    end

    it "exponentiates with negative powers" do
      result = br(17, 11) ** -5
      result.should eq(br(161051, 1419857))
    end

    it "cannot raise 0 to a negative power" do
      expect_raises(DivisionByZeroError) { br(0, 1) ** -1 }
    end
  end

  it "#ceil" do
    br(2, 1).ceil.should eq(2)
    br(21, 10).ceil.should eq(3)
    br(29, 10).ceil.should eq(3)

    br(201, 100).ceil.should eq(3)
    br(211, 100).ceil.should eq(3)
    br(291, 100).ceil.should eq(3)

    br(-201, 100).ceil.should eq(-2)
    br(-291, 100).ceil.should eq(-2)
  end

  it "#floor" do
    br(21, 10).floor.should eq(2)
    br(29, 10).floor.should eq(2)
    br(-29, 10).floor.should eq(-3)

    br(211, 100).floor.should eq(2)
    br(291, 100).floor.should eq(2)
    br(-291, 100).floor.should eq(-3)
  end

  it "#trunc" do
    br(21, 10).trunc.should eq(2)
    br(29, 10).trunc.should eq(2)
    br(-29, 10).trunc.should eq(-2)

    br(211, 100).trunc.should eq(2)
    br(291, 100).trunc.should eq(2)
    br(-291, 100).trunc.should eq(-2)
  end

  describe "#round" do
    describe "rounding modes" do
      it "to_zero" do
        br(-9, 6).round(:to_zero).should eq BigRational.new(-1)
        br(-6, 6).round(:to_zero).should eq BigRational.new(-1)
        br(-5, 6).round(:to_zero).should eq BigRational.new(0)
        br(-3, 6).round(:to_zero).should eq BigRational.new(0)
        br(-1, 6).round(:to_zero).should eq BigRational.new(0)
        br(0, 6).round(:to_zero).should eq BigRational.new(0)
        br(1, 6).round(:to_zero).should eq BigRational.new(0)
        br(3, 6).round(:to_zero).should eq BigRational.new(0)
        br(5, 6).round(:to_zero).should eq BigRational.new(0)
        br(6, 6).round(:to_zero).should eq BigRational.new(1)
        br(9, 6).round(:to_zero).should eq BigRational.new(1)
      end

      it "to_positive" do
        br(-9, 6).round(:to_positive).should eq BigRational.new(-1)
        br(-6, 6).round(:to_positive).should eq BigRational.new(-1)
        br(-5, 6).round(:to_positive).should eq BigRational.new(0)
        br(-3, 6).round(:to_positive).should eq BigRational.new(0)
        br(-1, 6).round(:to_positive).should eq BigRational.new(0)
        br(0, 6).round(:to_positive).should eq BigRational.new(0)
        br(1, 6).round(:to_positive).should eq BigRational.new(1)
        br(3, 6).round(:to_positive).should eq BigRational.new(1)
        br(5, 6).round(:to_positive).should eq BigRational.new(1)
        br(6, 6).round(:to_positive).should eq BigRational.new(1)
        br(9, 6).round(:to_positive).should eq BigRational.new(2)
      end

      it "to_negative" do
        br(-9, 6).round(:to_negative).should eq BigRational.new(-2)
        br(-6, 6).round(:to_negative).should eq BigRational.new(-1)
        br(-5, 6).round(:to_negative).should eq BigRational.new(-1)
        br(-3, 6).round(:to_negative).should eq BigRational.new(-1)
        br(-1, 6).round(:to_negative).should eq BigRational.new(-1)
        br(0, 6).round(:to_negative).should eq BigRational.new(0)
        br(1, 6).round(:to_negative).should eq BigRational.new(0)
        br(3, 6).round(:to_negative).should eq BigRational.new(0)
        br(5, 6).round(:to_negative).should eq BigRational.new(0)
        br(6, 6).round(:to_negative).should eq BigRational.new(1)
        br(9, 6).round(:to_negative).should eq BigRational.new(1)
      end

      it "ties_even" do
        br(-15, 6).round(:ties_even).should eq BigRational.new(-2)
        br(-9, 6).round(:ties_even).should eq BigRational.new(-2)
        br(-6, 6).round(:ties_even).should eq BigRational.new(-1)
        br(-5, 6).round(:ties_even).should eq BigRational.new(-1)
        br(-3, 6).round(:ties_even).should eq BigRational.new(0)
        br(-1, 6).round(:ties_even).should eq BigRational.new(0)
        br(0, 6).round(:ties_even).should eq BigRational.new(0)
        br(1, 6).round(:ties_even).should eq BigRational.new(0)
        br(3, 6).round(:ties_even).should eq BigRational.new(0)
        br(5, 6).round(:ties_even).should eq BigRational.new(1)
        br(6, 6).round(:ties_even).should eq BigRational.new(1)
        br(9, 6).round(:ties_even).should eq BigRational.new(2)
        br(15, 6).round(:ties_even).should eq BigRational.new(2)
      end

      it "ties_away" do
        br(-15, 6).round(:ties_away).should eq BigRational.new(-3)
        br(-9, 6).round(:ties_away).should eq BigRational.new(-2)
        br(-6, 6).round(:ties_away).should eq BigRational.new(-1)
        br(-5, 6).round(:ties_away).should eq BigRational.new(-1)
        br(-3, 6).round(:ties_away).should eq BigRational.new(-1)
        br(-1, 6).round(:ties_away).should eq BigRational.new(0)
        br(0, 6).round(:ties_away).should eq BigRational.new(0)
        br(1, 6).round(:ties_away).should eq BigRational.new(0)
        br(3, 6).round(:ties_away).should eq BigRational.new(1)
        br(5, 6).round(:ties_away).should eq BigRational.new(1)
        br(6, 6).round(:ties_away).should eq BigRational.new(1)
        br(9, 6).round(:ties_away).should eq BigRational.new(2)
        br(15, 6).round(:ties_away).should eq BigRational.new(3)
      end

      it "default (=ties_even)" do
        br(-15, 6).round.should eq BigRational.new(-2)
        br(-9, 6).round.should eq BigRational.new(-2)
        br(-6, 6).round.should eq BigRational.new(-1)
        br(-5, 6).round.should eq BigRational.new(-1)
        br(-3, 6).round.should eq BigRational.new(0)
        br(-1, 6).round.should eq BigRational.new(0)
        br(0, 6).round.should eq BigRational.new(0)
        br(1, 6).round.should eq BigRational.new(0)
        br(3, 6).round.should eq BigRational.new(0)
        br(5, 6).round.should eq BigRational.new(1)
        br(6, 6).round.should eq BigRational.new(1)
        br(9, 6).round.should eq BigRational.new(2)
        br(15, 6).round.should eq BigRational.new(2)
      end
    end
  end

  describe "#integer?" do
    it { br(0, 1).integer?.should be_true }
    it { br(1, 1).integer?.should be_true }
    it { br(9, 3).integer?.should be_true }
    it { br(-126, 7).integer?.should be_true }
    it { br(5, 2).integer?.should be_false }
    it { br(7, -3).integer?.should be_false }
  end

  it "is a number" do
    br(10, 3).is_a?(Number).should be_true
  end

  it "clones" do
    x = br(10, 3)
    x.clone.should eq(x)
  end

  describe "#inspect" do
    it { 123.to_big_r.inspect.should eq("123") }
  end

  it "#format" do
    br(100, 3).format.should eq("100/3")
    br(1234567, 890123).format.should eq("1,234,567/890,123")
    br(1234567, 890123).format(".", " ").should eq("1 234 567/890 123")
    br(1234567, 890123).format(".", " ", group: 2).should eq("1 23 45 67/89 01 23")
    br(1234567, 890123).format(",", ".", group: 4).should eq("123.4567/89.0123")
  end
end

describe "BigRational Math" do
  it "sqrt" do
    Math.sqrt(BigRational.new(BigInt.new("1" + "0"*48), 1)).should eq(BigFloat.new("1" + "0"*24))
  end
end
