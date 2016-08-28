require 'tumugi/atomic_file'

module Tumugi
  module Plugin
    module GoogleDrive
      class AtomicFile < Tumugi::AtomicFile
        attr_reader :id

        def initialize(path, fs, file_id: nil, parents: nil, mime_type: nil)
          super(path)
          @fs = fs
          @parents = parents
          @id = file_id.nil? ? fs.generate_file_id : file_id
          @mime_type = mime_type

          # https://developers.google.com/drive/v3/web/manage-uploads#uploading_using_a_pregenerated_id
          # Pregenerated IDs are not supported for native Google Document creation,
          # or uploads where conversion to native Google Document format is requested.
          if fs.google_drive_document?(mime_type)
            @id = nil
          end
        end

        def move_to_final_destination(temp_file)
          file = @fs.upload(temp_file, path, file_id: @id, parents: @parents, mime_type: @mime_type)
          @id = file.id unless @id
        end
      end
    end
  end
end
