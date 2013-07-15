require 'debugger'
module Statsample
  module ARIMA
    class ARIMA < Statsample::TimeSeries

      def arima(ds, p, i, q)
        if q.zero? 
          self.ar(p)
        elsif p.zero?
          self.ma(p)
        end
      end

      def ar(p)
        #AutoRegressive part of model
        #http://en.wikipedia.org/wiki/Autoregressive_model#Definition
        #For finding parameters(to fit), we will use either Yule-walker
        #or Burg's algorithm(more efficient)

        degugger

      end

      def yule_walker()
      end

      #tentative AR(p) simulator
      def ar_sim(n, phi, sigma)
        #using random number generator for inclusion of white noise
        err_nor = Distribution::Normal.rng(0, sigma)

        a = Array.new(n, 0)

        #For now "phi" are the known model parameters
        #later we will obtain it by Yule-walker/Burg

        1.upto(n) do |i|
          summation = 0
          phi.each_with_index do |phi_i, j|
            summation += phi_i * x[i - j - 1]
          end
          x[i] = summation + err_nor.call()
        end
        x
      end

      #moving average simulator - ongoing
      def ma_sim(series, q, n, phi, sigma)
        #series is a time-series
        #q is the order for this moving average model
        #n is number of observations (eg: 1000)
        #phi are the model parameters containting q values

        mean = series.mean()
        whitenoise_gen = Distribution::Normal.rng(0, sigma)
        a = Array.new(n, 0)

        1.upto(n) do |i|
          #aggregation from parameters and noise
          phi.each_with_index do |phi_i, j|
            x[i] += phi_i * whitenoise_gen.call()
            #^actually, we need backshifted lagged error terms here.
          end
          x[i] += mean + whitenoise_gen.call()
        end
        x
      end
    end
  end
end
