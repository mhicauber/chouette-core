require 'bundler'
Bundler.setup

require 'derailed_benchmarks'
require 'derailed_benchmarks/tasks'

if user_email = ENV["USER_EMAIL"]
  puts "Use user #{user_email}"

  ENV["USE_AUTH"] = "true"
  DerailedBenchmarks.auth.user = -> { User.find_by email: user_email }
else
  puts "No user email specified (by USER_EMAIL env variable)"
end
