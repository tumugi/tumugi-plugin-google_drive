require_relative '../../test_helper'
require 'tumugi/plugin/google_drive/atomic_file'
require 'tumugi/plugin/google_drive/file_system'

class Tumugi::Plugin::GoogleDrive::AtomicFileTest < Test::Unit::TestCase
  setup do
    @fs = Tumugi::Plugin::GoogleDrive::FileSystem.new(credential)
  end

  test "after open and close file, file upload to Google Drive" do
    path = 'test.txt'
    file = Tumugi::Plugin::GoogleDrive::AtomicFile.new(path, @fs)
    file.open do |f|
      f.puts 'test'
    end
    @fs.exist?(file.id)
    @fs.download(file.id) do |f|
      assert_equal("test\n", f.read)
    end
  end
end
