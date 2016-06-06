require 'tumugi'
require_relative '../target/google_drive_folder'

module Tumugi
  module Plugin
    class GoogleDriveFolderTask < Tumugi::Task
      Tumugi::Plugin.register_task('google_drive_folder', self)

      param :name, type: :string, required: true
      param :folder_id, type: :string
      param :parent, type: :string

      def output
        @output ||= Tumugi::Plugin::GoogleDriveFolderTarget.new(folder_id: folder_id, name: name, parents: parent.nil? ? nil : [parent])
      end

      def run
        if output.exist?
          log "skip: #{output} is already exists"
        else
          log "create folder: #{output}"
          output.fs.mkdir(name, folder_id: output.folder_id, parents: output.parents)
        end
      end
    end
  end
end
