require 'tumugi/atomic_file'

module Tumugi
  module Plugin
    module GoogleDrive
      class AtomicFile < Tumugi::AtomicFile
        attr_reader :id

        def initialize(path, fs, file_id: nil, parents: nil)
          super(path)
          @fs = fs
          @parents = parents
          @id = (file_id.nil? ? @fs.generate_file_id : file_id)
        end

        def move_to_final_destination(temp_file)
          @fs.upload(temp_file, path, file_id: @id, parents: @parents)
        end
      end
    end
  end
end
