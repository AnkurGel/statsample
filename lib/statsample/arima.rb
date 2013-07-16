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

        x = Array.new(n, 0)

        #For now "phi" are the known model parameters
        #later we will obtain it by Yule-walker/Burg

        1.upto(n) do |i|
          if i <= phi.size
            #dependent on previous accumulation of x
            backshifts = Statsample::Vector.new(x[0...i].reverse ,:scale)
          else
            #dependent on number of phi size/order
            backshifts = Statsample::Vector.new(x[(i - phi.size)...i].reverse, :scale)
          end
          parameters = Statsample::Vector.new(phi[0...backshifts.size] ,:scale)

          summation = (backshifts * parameters).inject(:+)
          x[i] += summation + err_nor.call()
        end
        x
      end

      #moving average simulator - ongoing
      def ma_sim(n, theta, sigma)
        #n is number of observations (eg: 1000)
        #theta are the model parameters containting q values
        #q is the order of MA

        mean = series.mean()
        whitenoise_gen = Distribution::Normal.rng(0, sigma)
        x = Array.new(n, 0)
        q = theta.size
        noise_arr = n.times.map { whitenoise_gen.call() }

        1.upto(n) do |i|
          #take care that noise vector doesn't try to index -ve value:
          if i <= q
            noises = Statsample::Vector.new(noise_arr[0..i].reverse, :scale)
          else
            noises = Statsample::Vector.new(noise_arr[(i-q)..i].reverse, :scale)
          end
          weights = [1] + Statsample::Vector.new(theta[0...noises.size - 1])

          summation = (weights * noises).inject(:+)
          x[i] += mean + summation
        end
        x
      end
    end
  end
end
