require_relative '../../test_helper'
require 'tumugi/plugin/target/google_drive_folder'

class Tumugi::Plugin::GoogleDriveFolderTargetTest < Test::Unit::TestCase
  sub_test_case "initialize" do
    test "with name" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test')
      assert_equal('test', target.name)
      assert_nil(target.parents)
      assert_nil(target.folder_id)
    end

    test "with name and parents" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test', parents: 'parent')
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_nil(target.folder_id)
    end

    test "with name and parents and file_id" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: 'test', parents: 'parent', folder_id: 'a'*28)
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_equal('a'*28, target.folder_id)
    end
  end

  sub_test_case "exist?" do
    test "match by folder_id" do
      fs = Tumugi::Plugin::GoogleDrive::FileSystem.new(Tumugi.config.section('google_drive'))
      folder1 = fs.mkdir('test', folder_id: fs.generate_file_id)
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(folder_id: folder1.id, name: folder1.name)
      assert_true(target.exist?)
    end

    test "match by name" do
      target = Tumugi::Plugin::GoogleDriveFolderTarget.new(name: SecureRandom.uuid)
      assert_false(target.exist?)
      target.fs.mkdir(target.name)
      assert_true(target.exist?)
    end
  end
end
