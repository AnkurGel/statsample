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

      def create_vector(arr)
        Statsample::Vector.new(arr, :scale)
      end

      #tentative AR(p) simulator
      def ar_sim(n, phi, sigma)
        #using random number generator for inclusion of white noise
        err_nor = Distribution::Normal.rng(0, sigma)
        #creating buffer with 10 random values
        buffer = Array.new(10, err_nor.call())

        x = buffer + Array.new(n, 0)

        #For now "phi" are the known model parameters
        #later we will obtain it by Yule-walker/Burg

        #instead of starting from 0, start from 11
        #and later take away buffer values for failsafe
        11.upto(n+11) do |i|
          if i <= phi.size
            #dependent on previous accumulation of x
            backshifts = create_vector(x[0...i].reverse)
          else
            #dependent on number of phi size/order
            backshifts = create_vector(x[(i - phi.size)...i].reverse)
          end
          parameters = create_vector(phi[0...backshifts.size])

          summation = (backshifts * parameters).inject(:+)
          x[i] = summation + err_nor.call()
        end
        x - buffer
      end

      #moving average simulator - ongoing
      def ma_sim(n, theta, sigma)
        #n is number of observations (eg: 1000)
        #theta are the model parameters containting q values
        #q is the order of MA
        include Statsample::TimeSeries
        mean = theta.to_ts.mean()
        whitenoise_gen = Distribution::Normal.rng(0, sigma)
        x = Array.new(n, 0)
        q = theta.size
        noise_arr = (n+1).times.map { whitenoise_gen.call() }

        1.upto(n) do |i|
          #take care that noise vector doesn't try to index -ve value:
          if i <= q
            noises = create_vector(noise_arr[0..i].reverse)
          else
            noises = create_vector(noise_arr[(i-q)..i].reverse)
          end
          weights = create_vector([1] + theta[0...noises.size - 1])


          summation = (weights * noises).inject(:+)
          x[i] = mean + summation
        end
        x
      end

    end
  end
end
