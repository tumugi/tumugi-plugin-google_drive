require_relative './test_helper'
require 'tumugi/cli'

class Tumugi::Plugin::GoogleDriveCLITest < Tumugi::Test::TumugiTestCase
  examples = {
    'example' => ['example.rb', 'task1'],
    'example2' => ['example2.rb', 'task1'],
  }

  setup do
    system('rm -rf tmp/*')
    sleep(1)
  end

  data do
    data_set = {}
    examples.each do |k, v|
      [1, 2, 8].each do |n|
        data_set["#{k}_workers_#{n}"] = (v.dup << n)
      end
    end
    data_set
  end
  test 'success' do |(file, task, worker)|
    assert_run_success("examples/#{file}", task, workers: worker, params: { "day" => "2016-06-01", "seed" => worker.to_s }, config: "./examples/tumugi_config_example.rb")
  end
end
