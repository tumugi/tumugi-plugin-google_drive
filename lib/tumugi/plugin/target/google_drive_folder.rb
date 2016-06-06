require 'tumugi/config'
require 'tumugi/plugin'
require 'tumugi/plugin/google_drive/file_system'

module Tumugi
  module Plugin
    class GoogleDriveFolderTarget < Tumugi::Target
      Tumugi::Plugin.register_target('google_drive_folder', self)

      attr_reader :folder_id, :name, :parents

      def initialize(folder_id: nil, name: nil, parents: nil, fs: nil)
        @fs = fs unless fs.nil?
        @folder_id = folder_id || self.fs.generate_file_id
        @name = name
        @parents = parents
      end

      def fs
        @fs ||= Tumugi::Plugin::GoogleDrive::FileSystem.new(Tumugi.config.section('google_drive'))
      end

      def exist?
        fs.exist?(folder_id)
      end

      def to_s
        s = "folder_id: #{folder_id}, name: #{name}"
        s += ", parents: #{parents}" if parents
        s
      end
    end
  end
end
