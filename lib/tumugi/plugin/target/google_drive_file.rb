require 'tumugi/config'
require 'tumugi/plugin'
require 'tumugi/plugin/file_system_target'
require 'tumugi/plugin/google_drive/atomic_file'
require 'tumugi/plugin/google_drive/file_system'

module Tumugi
  module Plugin
    class GoogleDriveFileTarget < Tumugi::Plugin::FileSystemTarget
      Tumugi::Plugin.register_target('google_drive_file', self)

      attr_reader :file_id, :name, :parents

      def initialize(file_id: nil, name:, parents: nil, fs: nil)
        @fs = fs unless fs.nil?
        @file_id = file_id
        @name = name
        @parents = parents
        super(file_id)
      end

      def fs
        @fs ||= Tumugi::Plugin::GoogleDrive::FileSystem.new(Tumugi.config.section('google_drive'))
      end

      def open(mode="r", &block)
        if mode.include? 'r'
          if file_id.nil?
            file = find_by_name(name)
            @file_id = file.id unless file.nil?
          end
          fs.download(file_id, mode: mode, &block)
        elsif mode.include? 'w'
          file = Tumugi::Plugin::GoogleDrive::AtomicFile.new(name, fs, file_id: file_id, parents: @parents)
          file.open(&block)
          @file_id = file.id
        else
          raise Tumugi::TumugiError.new("Invalid mode: #{mode}")
        end
      end

      def exist?
        if file_id
          fs.exist?(file_id)
        else
          !!find_by_name(name)
        end
      end

      def to_s
        s = "file_id: #{file_id}, name: #{name}"
        s += ", parents: #{parents}" if parents
        s
      end

      def url
        "https://drive.google.com/file/d/#{file_id}/view?usp=sharing"
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
          query += ")"
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
