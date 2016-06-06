require_relative '../../test_helper'
require 'tumugi/plugin/target/google_drive_file'

class Tumugi::Plugin::GoogleDriveFileTargetTest < Test::Unit::TestCase
  setup do
    @target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test')
    @file1 = @target.fs.put_string('test', 'file1.txt')
  end

  sub_test_case "initialize" do
    test "with name" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test')
      assert_equal('test', target.name)
      assert_nil(target.parents)
      assert_match(/^[0-9a-zA-Z]{28}$/, target.file_id)
      assert_equal(target.path, target.file_id)
    end

    test "with name and parents" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test', parents: 'parent')
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_match(/^[0-9a-zA-Z]{28}$/, target.file_id)
      assert_equal(target.path, target.file_id)
    end

    test "with name and parents and file_id" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test', parents: 'parent', file_id: 'a'*28)
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_equal('a'*28, target.file_id)
      assert_equal(target.path, target.file_id)
    end
  end

  test "exist?" do
    readable_target = Tumugi::Plugin::GoogleDriveFileTarget.new(file_id: @file1.id)
    assert_true(readable_target.exist?)
    assert_false(@target.exist?)
  end

  sub_test_case "open" do
    test "write and read" do
      @target.open("w") do |f|
        f.puts("test")
      end
      @target.open("r") do |f|
        assert_equal("test\n", f.read)
      end
    end

    test "raise error when mode is invalid" do
      assert_raise(Tumugi::TumugiError) do
        @target.open("z")
      end
    end
  end
end
