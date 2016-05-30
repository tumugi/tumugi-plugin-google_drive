require 'tumugi/config'
require 'tumugi/plugin'
#require 'tumugi/plugin/gcs/atomic_gcs_file'
#require 'tumugi/plugin/gcs/gcs_file_system'

module Tumugi
  module Plugin
    class GoogleDriveFileTarget < Tumugi::Target
      Tumugi::Plugin.register_target('google_drive_file', self)
      Tumugi::Config.register_section('google_drive', :client_id, :client_secret, :refresh_token)

      attr_reader :key, :folder

      def initialize(key:, folder: nil)
        @key = key
        @folder = folder
        log "key='#{key}, folder='#{folder}'"
      end

      def exist?
        true #TODO
      end

      def uri
        "https://drive.google.com/open?id=#{key}"
      end

      def to_s
        uri
      end
    end
  end
end
