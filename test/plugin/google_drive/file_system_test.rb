require_relative '../../test_helper'
require 'tumugi/plugin/google_drive/file_system'

class Tumugi::Plugin::GoogleDrive::FileSystemTest < Test::Unit::TestCase
  setup do
    @fs = Tumugi::Plugin::GoogleDrive::FileSystem.new(credential)
    @file1 = @fs.put_string('test', 'file1.txt')
    @file2 = @fs.put_string(JSON.generate(key: 'value'), 'file2.json', content_type: 'application/json')
  end

  teardown do
    # Wait to prevent 'User Rate Limit Exceeded' error on Travis
    sleep 3 if ENV.key?('TRAVIS')
  end

  test 'initialize with JSON key file' do
    fs = Tumugi::Plugin::GoogleDrive::FileSystem.new(credential_file)
    assert_true(fs.exist?(@file1.id))
  end

  test 'exist?' do
    assert_true(@fs.exist?(@file1.id))
    assert_true(@fs.exist?(@file2.id))
    assert_false(@fs.exist?('invalid_id'))
  end

  test 'remove' do
    assert_true(@fs.exist?(@file1.id))
    @fs.remove(@file1.id)
    assert_false(@fs.exist?(@file1.id))
  end

  test 'mkdir' do
    dir = @fs.mkdir('test_directory')
    assert_true(@fs.exist?(dir.id))
    assert_true(@fs.directory?(dir.id))
  end

  test 'move' do
    file = @fs.move(@file1.id, 'dest_file1.txt')
    assert_true(@fs.exist?(file.id))
  end

  test 'copy' do
    file = @fs.move(@file2.id, 'dest_file2.txt')
    assert_true(@fs.exist?(file.id))
    assert_equal('dest_file2.txt', file.name)
  end

  sub_test_case "put_string" do
    test "without parents" do
      file = @fs.put_string('test', 'test.txt')
      assert_true(@fs.exist?(file.id))
    end

    test "with parents" do
      file = @fs.put_string('test', 'test.txt', parents: '0B62A9ARqgG8zWS1jcUQ3SkhQdzA')
      assert_true(@fs.exist?(file.id))
    end
  end

  sub_test_case "upload and donwload" do
    test "without parents" do
      File.open('tmp/upload.txt', 'w') {|f| f.puts 'test'}
      file = @fs.upload('tmp/upload.txt', 'upload.txt')
      assert_true(@fs.exist?(file.id))
      @fs.download(file.id) do |f|
        assert_equal("test\n", f.read)
      end
    end

    test "with parents" do
      File.open('tmp/upload.txt', 'w') {|f| f.puts 'test'}
      file = @fs.upload('tmp/upload.txt', 'upload.txt', parents: '0B62A9ARqgG8zWS1jcUQ3SkhQdzA')
      assert_true(@fs.exist?(file.id))
      @fs.download(file.id) do |f|
        assert_equal("test\n", f.read)
      end
    end
  end

  test "upload and remove" do
    file = @fs.put_string('test', 'test.txt')
    assert_true(@fs.exist?(file.id))
    @fs.remove(file.id)
    assert_false(@fs.exist?(file.id))
  end

  test "generate file id" do
    id = @fs.generate_file_id
    assert_match(/^[0-9a-zA-Z]{28}$/, id)
  end
end
