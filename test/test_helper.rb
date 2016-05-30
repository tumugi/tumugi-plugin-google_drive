require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'test/unit/rr'

require 'tumugi'

Dir.mkdir('tmp') unless Dir.exist?('tmp')

def credential
  pkey = ENV['PRIVATE_KEY'].gsub(/\\n/, "\n")
  {
    project_id: ENV['PROJECT_ID'],
    client_email: ENV['CLIENT_EMAIL'],
    private_key: pkey
  }
end

Tumugi.configure do |config|
  config.section('google_drive') do |section|
    section.project_id = credential[:project_id]
    section.client_email = credential[:client_email]
    section.private_key = credential[:private_key]
  end
end
