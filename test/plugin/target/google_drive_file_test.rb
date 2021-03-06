require_relative '../../test_helper'
require 'tumugi/plugin/target/google_drive_file'

class Tumugi::Plugin::GoogleDriveFileTargetTest < Test::Unit::TestCase
  setup do
    @target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: SecureRandom.uuid)
  end

  sub_test_case "initialize" do
    test "with name" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test')
      assert_equal('test', target.name)
      assert_nil(target.parents)
      assert_nil(target.file_id)
      assert_equal(target.path, target.file_id)
      assert_nil(target.mime_type)
    end

    test "with name and parents" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test', parents: 'parent')
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_nil(target.file_id)
      assert_equal(target.path, target.file_id)
      assert_nil(target.mime_type)
    end

    test "with name and parents and file_id" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test', parents: 'parent', file_id: 'a'*28)
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_equal('a'*28, target.file_id)
      assert_equal(target.path, target.file_id)
      assert_nil(target.mime_type)
    end

    test "with name and parents and file_id and mime_type" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'test', parents: 'parent', file_id: 'a'*28, mime_type: 'text/plain')
      assert_equal('test', target.name)
      assert_equal('parent', target.parents)
      assert_equal('a'*28, target.file_id)
      assert_equal(target.path, target.file_id)
      assert_equal('text/plain', target.mime_type)
    end
  end

  sub_test_case "exist?" do
    test "match_by file_id" do
      file1 = @target.fs.put_string('test', 'file1.txt')
      readable_target = Tumugi::Plugin::GoogleDriveFileTarget.new(file_id: file1.id, name: 'test')
      assert_true(readable_target.exist?)
      assert_false(@target.exist?)
    end

    test "match_by name" do
      name = SecureRandom.uuid
      file1 = @target.fs.put_string('test', name)
      target1 = Tumugi::Plugin::GoogleDriveFileTarget.new(name: file1.name)
      target2 = Tumugi::Plugin::GoogleDriveFileTarget.new(name: SecureRandom.uuid)
      assert_true(target1.exist?)
      assert_false(target2.exist?)
    end

    test "match_by :name with parents" do
      name = SecureRandom.uuid
      parents = '0B62A9ARqgG8zWS1jcUQ3SkhQdzA'
      file1 = @target.fs.put_string('test', name, parents: parents)
      target1 = Tumugi::Plugin::GoogleDriveFileTarget.new(name: file1.name, parents: parents)
      target2 = Tumugi::Plugin::GoogleDriveFileTarget.new(name: SecureRandom.uuid, parents: parents)
      assert_true(target1.exist?)
      assert_false(target2.exist?)
    end

    test 'raise error when multiple file found match by name' do
      name = SecureRandom.uuid
      @target.fs.put_string('test', name)
      @target.fs.put_string('test', name)
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: name)
      assert_raise(Tumugi::TumugiError) do
        target.exist?
      end
    end
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

    test "write and read with parents" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: 'file1.txt', parents: '0B62A9ARqgG8zWS1jcUQ3SkhQdzA')

      target.open("w") do |f|
        f.puts("test")
      end
      target.open("r") do |f|
        assert_equal("test\n", f.read)
      end
    end

    test "write and read with mime_type" do
      target = Tumugi::Plugin::GoogleDriveFileTarget.new(name: "#{SecureRandom.uuid}.csv")

      target.open("w", mime_type: "application/vnd.google-apps.spreadsheet") do |f|
        f.puts "head1,head2\nvalue1,value2"
      end
      target.open("r", mime_type: "text/csv") do |f|
        assert_equal("head1,head2\r\nvalue1,value2", f.read)
      end
    end

    test "raise error when mode is invalid" do
      assert_raise(Tumugi::TumugiError) do
        @target.open("z")
      end
    end
  end

  test "url" do
    @target.open("w") do |f|
      f.puts("test")
    end
    assert_equal("https://drive.google.com/file/d/#{@target.file_id}/view?usp=drivesdk", @target.url)
  end
end
