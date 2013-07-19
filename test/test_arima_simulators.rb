require(File.expand_path(File.dirname(__FILE__)+'/helpers_tests.rb'))

class StatsampleArimaSimulatorsTest < MiniTest::Unit::TestCase
  context("ARIMA simulations") do
    include Statsample::ARIMA

    setup do
      @series = ARIMA.new
      @ar_1_positive = @series.ar_sim(1500, [0.9], 2)
      @ar_1_negative = @series.ar_sim(1500, [-0.9], 2)
    end

    def generate_acf(simulation)
      ts = simulation.to_ts
      ts.acf
    end

    def generate_pacf(simulation)
      ts = simulation.to_ts
      ts.pacf
    end

    should "have exponential decay of acf on positive side for AR(1) with phi > 0" do
      @ar = @ar_1_positive
      @acf = generate_acf(@ar)
      assert_equal @acf[0], 1.0
      assert_operator @acf[1], :>=, 0.7
      assert_operator @acf[@acf.size - 1], :<=, 0.2
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_positive_phi_acf.png
    end

    should "have series with alternating sign on acf starting on negative side for AR(1) with phi < 0" do
      @ar = @ar_1_negative
      @acf = generate_acf(@ar)
      assert_equal @acf[0], 1.0
      #testing for alternating series
      assert_operator @acf[1], :<, 0
      assert_operator @acf[2], :>, 0
      assert_operator @acf[3], :<, 0
      assert_operator @acf[4], :>, 0
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi_acf.png
    end

    should "have positive spike on pacf at lag 1 for AR(1) for phi > 0" do
      @ar = @ar_1_positive
      @pacf = generate_pacf(@ar)
      assert_operator @pacf[1], :>=, 0.7
      assert_operator @pacf[2], :<=, 0.2
      assert_operator @pacf[3], :<=, 0.14
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_postive_phi_pacf.png
    end

    should "have negative spike on pacf at lag 1 for AR(1) for phi < 0" do
      @ar = @ar_1_negative
      @pacf = generate_pacf(@ar)
      assert_operator @pacf[1], :<=, 0
      assert_operator @pacf[1], :<=, -0.5
      assert_operator @pacf[2], :>=, -0.5
      #visualizaton:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi_pacf.png
      #[hided @pacf[0] = 1 to convey accurate picture]
    end
  end
end

