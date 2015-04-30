require 'curb'

module CurbConcurrencyTestApp

  BACKEND_REQUESTS = 5

  class Easy
    def call(env)
      start = Time.now.to_f
      successes = BACKEND_REQUESTS.times.map { Curl::Easy.perform('http://localhost:12621/') }
      delta = ((Time.now.to_f - start) * 100_000).to_i / 100.0

      if successes.compact.size < BACKEND_REQUESTS
        [503, {}, ["Upstream responded #{successes.compact.size} out of #{BACKEND_REQUESTS} times in #{delta}ms."]]
      else
        [200, {}, ["Upstream responded all #{BACKEND_REQUESTS} times in #{delta}ms."]]
      end
    end
  end

  class Multi
    def call(env)
      start = Time.now.to_f

      successes = Array.new(BACKEND_REQUESTS)
      errors = Array.new(BACKEND_REQUESTS)

      multi = Curl::Multi.new
      BACKEND_REQUESTS.times do |index|
        ce = Curl::Easy.new('http://localhost:12621/') do |easy|
          easy.on_success { |curl| successes[index] = curl }
          easy.on_failure { |curl, rc| errors[index] = "Error: #{easy.url}\n   RC: #{rc.inspect}" }
        end
        multi.add(ce)
      end

      multi.perform
      delta = ((Time.now.to_f - start) * 100_000).to_i / 100.0

      if successes.compact.size < BACKEND_REQUESTS
        errors.each { |error| $stderr.puts error }
        [503, {}, ["Upstream responded #{successes.compact.size} out of #{BACKEND_REQUESTS} times in #{delta}ms."]]
      else
        [200, {}, ["Upstream responded all #{BACKEND_REQUESTS} times in #{delta}ms."]]
      end
    end
  end

  class Sleep
    def call(env)
      sleep 0.05
      [200, {}, 'Hello world!']
    end
  end

end
