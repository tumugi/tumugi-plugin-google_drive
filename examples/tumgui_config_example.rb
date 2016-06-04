Tumugi.configure do |config|
  config.section('google_drive') do |section|
    section.project_id = ENV["PROJECT_ID"]
    section.client_email = ENV["CLIENT_EMAIL"]
    section.private_key = ENV["PRIVATE_KEY"].gsub(/\\n/, "\n")
  end
end
