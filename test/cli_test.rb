require_relative './test_helper'
require 'tumugi/cli'

class Tumugi::Plugin::GoogleDriveCLITest < Test::Unit::TestCase
  examples = {
    'example' => ['example.rb', 'task1'],
  }

  def invoke(file, task, options)
    Tumugi::CLI.new.invoke(:run_, [task], options.merge(file: "./examples/#{file}", quiet: true))
  end

  data(examples)
  test 'success' do |(file, task)|
    assert_true(invoke(file, task, worker: 4, params: { 'day' => '2016-05-01' }, config: "./examples/tumugi_config_example.rb"))
  end
end
