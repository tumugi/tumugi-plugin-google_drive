require 'tumugi/config'
require 'tumugi/plugin'
require 'tumugi/plugin/google_drive/file_system'

module Tumugi
  module Plugin
    class GoogleDriveFolderTarget < Tumugi::Target
      Tumugi::Plugin.register_target('google_drive_folder', self)

      attr_reader :folder_id, :name, :parents

      def initialize(folder_id: nil, name:, parents: nil, fs: nil)
        @fs = fs unless fs.nil?
        @folder_id = folder_id
        @name = name
        @parents = parents
      end

      def fs
        @fs ||= Tumugi::Plugin::GoogleDrive::FileSystem.new(Tumugi.config.section('google_drive'))
      end

      def exist?
        if folder_id
          fs.exist?(folder_id)
        else
          !find_by_name(name).nil?
        end
      end

      def mkdir
        fid = folder_id || fs.generate_file_id
        fs.mkdir(name, folder_id: fid, parents: parents)
        @folder_id = fid
      end

      def to_s
        s = "folder_id: #{folder_id}, name: #{name}"
        s += ", parents: #{parents}" if parents
        s
      end

      def url
        return nil if folder_id.nil?
        folder = fs.get_file_metadata(folder_id)
        folder.web_view_link
      end

      private

      def find_by_name(n)
        query =  "name='#{n}'"
        ps = parents
        if parents.is_a?(String)
          ps = [parents]
        end
        if parents
          query += " and ("
          query += "#{ps.map{|p| "'#{p}' in parents"}.join(" or ")}"
          query += ") and mime_type = '#{Tumugi::Plugin::GoogleDrive::MimeTypes::DRIVE_FOLDER}'"
        end
        files = fs.list_files(query: query, page_size: 2).files
        if files.size == 0
          nil
        elsif files.size == 1
          files.first
        else
          raise Tumugi::TumugiError.new("Multiple files find for query: #{query}")
        end
      end
    end
  end
end
