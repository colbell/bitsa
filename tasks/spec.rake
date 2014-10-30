require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) {}

# desc  "Run all specs with rcov"
# RSpec::Core::RakeTask.new(:rcov) do |t|
#   t.rcov = true
#   t.rcov_opts = %w{--exclude spec\/,gems\/}
# end
