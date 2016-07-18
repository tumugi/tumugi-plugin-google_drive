require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

raise "ENV['PROJECT_ID'] must be set" unless ENV.key?('PROJECT_ID')
raise "ENV['CLIENT_EMAIL'] must be set" unless ENV.key?('CLIENT_EMAIL')
raise "ENV['PRIVATE_KEY'] must be set" unless ENV.key?('PRIVATE_KEY')

require 'test/unit'
require 'test/unit/rr'

require 'tumugi'
require 'tumugi/test/helper'
include Tumugi::Test::Helpers

require 'json'

Dir.mkdir('tmp') unless Dir.exist?('tmp')

def credential
  pkey = ENV['PRIVATE_KEY'].gsub(/\\n/, "\n")
  OpenStruct.new({
    project_id: ENV['PROJECT_ID'],
    client_email: ENV['CLIENT_EMAIL'],
    private_key: pkey
  })
end

def credential_file
  file = 'tmp/credential.json'
  pkey = ENV['PRIVATE_KEY'].gsub(/\\n/, "\n")
  File.write(file, JSON.generate({
    project_id: ENV['PROJECT_ID'],
    client_email: ENV['CLIENT_EMAIL'],
    private_key: pkey
  }))
  OpenStruct.new(private_key_file: file)
end

Tumugi.configure do |config|
  config.section('google_drive') do |section|
    section.project_id = credential[:project_id]
    section.client_email = credential[:client_email]
    section.private_key = credential[:private_key]
  end
end
