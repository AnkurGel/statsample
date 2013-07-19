require(File.expand_path(File.dirname(__FILE__)+'/helpers_tests.rb'))

class StatsampleArimaSimulatorsTest < MiniTest::Unit::TestCase
  context("ARIMA simulations") do
    include Statsample::ARIMA

    setup do
      @series = ARIMA.new
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
      @ar = @series.ar_sim(1500, [0.9], 2)
      @acf = generate_acf(@ar)
      assert_equal @acf[0], 1.0
      assert_operator @acf[1], :>=, 0.7
      assert_operator @acf[@acf.size - 1], :<=, 0.2
      #visualization: https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_positive_phi.png
    end

    should "have series with alternating sign starting on negative side for AR(1) with phi < 0" do
      @ar = @series.ar_sim(1500, [-0.9], 2)
      @acf = generate_acf(@ar)
      assert_equal @acf[0], 1.0
      #testing for alternating series
      assert_operator @acf[1], :<, 0
      assert_operator @acf[2], :>, 0
      assert_operator @acf[3], :<, 0
      assert_operator @acf[4], :>, 0
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi.png
    end
  end
end
