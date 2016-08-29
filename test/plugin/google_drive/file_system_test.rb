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

    test "convert google docs <=> text" do
      File.open('tmp/upload.csv', 'w') {|f| f.puts "head1,head2\nvalue1,value2"}
      file = @fs.upload('tmp/upload.csv', 'upload.csv', mime_type: 'application/vnd.google-apps.spreadsheet')
      assert_true(@fs.exist?(file.id))
      assert_equal('application/vnd.google-apps.spreadsheet', file.mime_type)
      @fs.download(file.id, mime_type: 'text/csv') do |f|
        assert_equal("head1,head2\r\nvalue1,value2", f.read)
      end
    end

    test "raise error when download google docs without mime_type" do
      File.open('tmp/upload.txt', 'w') {|f| f.puts 'test'}
      file = @fs.upload('tmp/upload.txt', 'upload.txt', mime_type: 'application/vnd.google-apps.document')
      assert_true(@fs.exist?(file.id))
      assert_equal('application/vnd.google-apps.document', file.mime_type)
      assert_raise(Tumugi::FileSystemError) do
        @fs.download(file.id)
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

  sub_test_case "list_files" do
    test "should return matched files" do
      names = [ SecureRandom.uuid, SecureRandom.uuid ]
      file_ids = []
      names.each do |name|
        f = @fs.put_string(name, name)
        file_ids << f.id
      end
      query = names.map{ |n| "name='#{n}'" }.join(" or ")

      files = []
      page_token = nil
      begin
        response = @fs.list_files(query: query, page_size: 1, page_token: page_token)
        assert_equal(1, response.files.size)
        for f in response.files
          files << f
        end
        page_token = response.next_page_token
      end while !page_token.nil?

      assert_equal(2, files.size)
      assert_equal(file_ids.sort, files.map(&:id).sort)
    end

    test "only return files in specified parent folder" do
      name1 = SecureRandom.uuid
      name2 = SecureRandom.uuid
      name3 = SecureRandom.uuid
      parents = '0B62A9ARqgG8zWS1jcUQ3SkhQdzA'

      file1 = @fs.put_string(name1, name1, parents: parents)
      file2 = @fs.put_string(name2, name2, parents: parents)
      @fs.put_string(name3, name3)

      response = @fs.list_files(query: "'#{parents}' in parents and (name='#{name1}' or name='#{name2}' or name='#{name3}')", page_size: 3)
      assert_nil(response.next_page_token)

      files = response.files
      assert_equal(2, files.size)
      assert_equal([file1.id, file2.id].sort, files.map(&:id).sort)
      assert_equal([parents], files.map(&:parents).flatten.uniq)
    end
  end

  test 'google_drive_document?' do
    assert_true(@fs.google_drive_document?('application/vnd.google-apps.document'))
    assert_true(@fs.google_drive_document?('application/vnd.google-apps.presentation'))
    assert_true(@fs.google_drive_document?('application/vnd.google-apps.spreadsheet'))

    assert_false(@fs.google_drive_document?(nil))
    assert_false(@fs.google_drive_document?('text/plain'))
    assert_false(@fs.google_drive_document?('image/png'))
  end
end
