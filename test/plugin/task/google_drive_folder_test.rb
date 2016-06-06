require_relative '../../test_helper'
require 'tumugi/plugin/task/google_drive_folder'

class Tumugi::Plugin::GoogleDriveFolderTaskTest < Test::Unit::TestCase
  setup do
    @klass = Class.new(Tumugi::Plugin::GoogleDriveFolderTask)
    @klass.param_set :name, 'folder1'
  end

  sub_test_case "parameters" do
    test "should set correctly" do
      task = @klass.new
      assert_equal('folder1', task.name)
      assert_nil(task.parent)
      assert_nil(task.folder_id)
    end

    data({
      "name" => [:name],
    })
    test "raise error when required parameter is not set" do |params|
      params.each do |param|
        @klass.param_set(param, nil)
      end
      assert_raise(Tumugi::ParameterError) do
        @klass.new
      end
    end
  end

  test "#output" do
    task = @klass.new
    output = task.output
    assert_true(output.is_a? Tumugi::Plugin::GoogleDriveFolderTarget)
    assert_equal('folder1', output.name)
    assert_match(/^[0-9a-zA-Z]{28}$/, output.folder_id)
    assert_equal(nil, output.parents)
  end

  test "#run" do
    task = @klass.new
    task.run
    assert_true(task.output.exist?)
  end
end
