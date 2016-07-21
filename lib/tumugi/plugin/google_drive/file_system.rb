require 'google/apis/drive_v3'
require 'tumugi/error'

Tumugi::Config.register_section('google_drive', :project_id, :client_email, :private_key, :private_key_file)

module Tumugi
  module Plugin
    module GoogleDrive
      class FileSystem

        MIME_TYPE_FOLDER = 'application/vnd.google-apps.folder'

        def initialize(config)
          save_config(config)
        end

        def exist?(file_id)
          client.get_file(file_id, options: request_options)
          true
        rescue => e
          return false if e.respond_to?(:status_code) && e.status_code == 404
          process_error(e)
        end

        def remove(file_id)
          return unless exist?(file_id)

          client.delete_file(file_id, options: request_options)
          wait_until { !exist?(file_id) }
          file_id
        rescue
          process_error($!)
        end

        def mkdir(name, folder_id: nil, parents: nil)
          file_metadata = Google::Apis::DriveV3::File.new({
            name: name,
            mime_type: MIME_TYPE_FOLDER,
            parents: parents,
            id: folder_id
          })
          file = client.create_file(file_metadata, options: request_options)
          wait_until { exist?(file.id) }
          file
        rescue
          process_error($!)
        end

        def directory?(file_id)
          file = client.get_file(file_id, options: request_options)
          file.mime_type == MIME_TYPE_FOLDER
        rescue
          process_error($!)
        end

        def move(src_file_id, dest_name, dest_parents: nil)
          file = copy(src_file_id, dest_name, dest_parents: dest_parents)
          remove(src_file_id)
          file
        end

        def copy(src_file_id, dest_name, dest_parents: nil)
          dest_parents = [dest_parents] if dest_parents.is_a?(String)
          dest_file_metadata = Google::Apis::DriveV3::File.new({
            name: dest_name,
            parents: dest_parents
          })
          file = client.copy_file(src_file_id, dest_file_metadata, options: request_options)
          wait_until { exist?(file.id) }
          file
        rescue
          process_error($!)
        end

        def upload(media, name, content_type: nil, file_id: nil, parents: nil)
          parents = [parents] if parents.is_a?(String)
          file_metadata = Google::Apis::DriveV3::File.new({
            id: file_id,
            name: name,
            parents: parents
          })
          file = client.create_file(file_metadata, upload_source: media, content_type: content_type, options: request_options)
          wait_until { exist?(file.id) }
          file
        rescue
          process_error($!)
        end

        def put_string(contents, name, content_type: 'text/plain', file_id: nil, parents: nil)
          media = StringIO.new(contents)
          upload(media, name, content_type: content_type, file_id: file_id, parents: parents)
        end

        def download(file_id, download_path: nil, mode: 'r', &block)
          if download_path.nil?
            download_path = Tempfile.new('tumugi_google_drive_file_system').path
          end
          client.get_file(file_id, download_dest: download_path, options: request_options)
          wait_until { File.exist?(download_path) }

          if block_given?
            File.open(download_path, mode, &block)
          else
            File.open(download_path, mode)
          end
        rescue
          process_error($!)
        end

        def generate_file_id
          client.generate_file_ids(count: 1, options: request_options).ids.first
        rescue
          process_error($!)
        end

        def list_files(query:, order_by: "name", spaces: "drive", fields: "next_page_token, files(id, name, parents, mime_type)", page_size: 100, page_token: nil)
          # https://developers.google.com/drive/v3/reference/files/list
          # https://developers.google.com/drive/v3/web/search-parameters
          client.list_files(q: query, order_by: order_by, spaces: spaces, fields: fields, page_size: page_size, page_token: page_token)
        rescue
          process_error($!)
        end

        private

        def save_config(config)
          if config.private_key_file.nil?
            @project_id = config.project_id
            client_email = config.client_email
            private_key = config.private_key
          elsif config.private_key_file
            json = JSON.parse(File.read(config.private_key_file))
            @project_id = json['project_id']
            client_email = json['client_email']
            private_key = json['private_key']
          end
          @key = {
            client_email: client_email,
            private_key: private_key
          }
        end

        def client
          return @cached_client if @cached_client && @cached_client_expiration > Time.now

          client = Google::Apis::DriveV3::DriveService.new
          scope = Google::Apis::DriveV3::AUTH_DRIVE

          if @key[:client_email] && @key[:private_key]
            options = {
              json_key_io: StringIO.new(JSON.generate(@key)),
              scope: scope
            }
            auth = Google::Auth::ServiceAccountCredentials.make_creds(options)
          else
            auth = Google::Auth.get_application_default([scope])
          end
          auth.fetch_access_token!
          client.authorization = auth

          @cached_client_expiration = Time.now + (auth.expires_in / 2)
          @cached_client = client
        end

        def wait_until(&block)
          while not block.call
            sleep 3
          end
        end

        def process_error(err)
          if err.respond_to?(:body)
            begin
              if err.body.nil?
                reason = err.status_code.to_s
                errors = "HTTP Status: #{err.status_code}\nHeaders: #{err.header.inspect}"
              else
                jobj = JSON.parse(err.body)
                error = jobj["error"]
                reason = error["errors"].map{|e| e["reason"]}.join(",")
                errors = error["errors"].map{|e| e["message"] }.join("\n")
              end
            rescue JSON::ParserError
              reason = err.status_code.to_s
              errors = "HTTP Status: #{err.status_code}\nHeaders: #{err.header.inspect}\nBody:\n#{err.body}"
            end
            raise Tumugi::FileSystemError.new(errors, reason)
          else
            raise err
          end
        end

        def request_options
          {
            retries: 5,
            timeout_sec: 60
          }
        end
      end
    end
  end
end
