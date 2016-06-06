require_relative '../../test_helper'
require 'tumugi/plugin/target/google_drive_folder'

class Tumugi::Plugin::GoogleDriveFolderTargetTest < Test::Unit::TestCase
  sub_test_case "initialize" do
    test "with name" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test')
      assert_equal('test', target.name)
      assert_nil(target.parents)
      assert_match(/^[0-9a-zA-Z]{28}$/, target.folder_id)
    end

    test "with name and parents" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test', parents: 'parent')
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_match(/^[0-9a-zA-Z]{28}$/, target.folder_id)
    end

    test "with name and parents and file_id" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test', parents: 'parent', folder_id: 'a'*28)
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_equal('a'*28, target.folder_id)
    end
  end

  test "exist?" do
    target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'folder1')
    folder1 = target.fs.mkdir('test', folder_id: target.folder_id)
    readable_target = Tumugi::Plugin::GoogleDriveFolderTarget.new(folder_id: folder1.id)
    assert_true(readable_target.exist?)
  end
end
