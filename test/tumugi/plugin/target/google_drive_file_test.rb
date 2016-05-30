require_relative '../../../test_helper'
require 'tumugi/plugin/target/google_drive_file'

class Tumugi::Plugin::GoogleDriveFileTargetTest < Test::Unit::TestCase
  setup do
    @target = Tumugi::Plugin::GoogleDriveFileTarget.new(key: 'test')
  end

  test "exist?" do
    assert_true(@target.exist?)
  end
end
