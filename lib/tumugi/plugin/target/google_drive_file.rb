require 'tumugi/config'
require 'tumugi/plugin'
require 'tumugi/plugin/file_system_target'
require 'tumugi/plugin/google_drive/atomic_file'
require 'tumugi/plugin/google_drive/file_system'

module Tumugi
  module Plugin
    class GoogleDriveFileTarget < Tumugi::Plugin::FileSystemTarget
      Tumugi::Plugin.register_target('google_drive_file', self)
      Tumugi::Config.register_section('google_drive', :project_id, :client_email, :private_key, :private_key_file)

      attr_reader :file_id, :name, :parents

      def initialize(file_id: nil, name: nil, parents: nil, fs: nil)
        @fs = fs unless fs.nil?
        @file_id = file_id || self.fs.generate_file_id
        @name = name
        @parents = parents
        super(@file_id)
      end

      def fs
        @fs ||= Tumugi::Plugin::GoogleDrive::FileSystem.new(Tumugi.config.section('google_drive'))
      end

      def open(mode="r", &block)
        if mode.include? 'r'
          fs.download(file_id, mode: mode, &block)
        elsif mode.include? 'w'
          file = Tumugi::Plugin::GoogleDrive::AtomicFile.new(name, fs)
          file.open(&block)
          @file_id = file.id
        else
          raise Tumugi::TumugiError.new('Invalid mode: #{mode}')
        end
      end

      def exist?
        if file_id.nil?
          false
        else
          fs.exist?(file_id)
        end
      end
    end
  end
end
