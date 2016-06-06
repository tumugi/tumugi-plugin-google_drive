[![Build Status](https://travis-ci.org/tumugi/tumugi-plugin-google_drive.svg?branch=master)](https://travis-ci.org/tumugi/tumugi-plugin-google_drive) [![Code Climate](https://codeclimate.com/github/tumugi/tumugi-plugin-google_drive/badges/gpa.svg)](https://codeclimate.com/github/tumugi/tumugi-plugin-google_drive) [![Coverage Status](https://coveralls.io/repos/github/tumugi/tumugi-plugin-google_drive/badge.svg?branch=master)](https://coveralls.io/github/tumugi/tumugi-plugin-google_drive?branch=master) [![Gem Version](https://badge.fury.io/rb/tumugi-plugin-google_drive.svg)](https://badge.fury.io/rb/tumugi-plugin-google_drive)

# tumugi-plugin-google_drive

[tumugi](https://github.com/tumugi/tumugi) plugin for Google Drive.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tumugi-plugin-google_drive'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install tumugi-plugin-google_drive
```

## Component

### Tumugi::Plugin::GoogleDriveFileTarget

This target represent file on Googl Drive.
This target has following parameters.

- name (required)
  - Filename **string**
- file_id
  - File ID **string**
- parents
  - Parent folder ID **string** or **array of string**

Tumugi workflow file using this target is like this:

```rb
task :task1 do
  param :day, type: :time, auto_bind: true, required: true
  output do
    target(:google_drive_file,
          name: "test_#{day.strftime('%Y%m%d')}.txt",
          parents: "xyz")
  end
  run do
    log 'task1#run'
    output.open('w') {|f| f.puts('done') }
  end
end
```

### Tumugi::Plugin::GoogleDriveFolderTarget

This target represent folder on Googl Drive.
This target has following parameters.

- name (required)
  - Folder name **string**
- folder_id
  - Folder ID **string**
- parents
  - Parent folder ID **string** or **array of string**

### Tumugi::Plugin::GoogleDriveFolderTask

This task create a folder on Googl Drive.
Tumugi workflow file using this task is like this:

```rb
task :task1, type: :google_drive_folder do
  param :day, type: :time, auto_bind: true, required: true
  output do
    target(:google_drive_folder,
          name: "test_#{day.strftime('%Y%m%d')}.txt",
          parents: "xyz")
  end
end
```

### Config Section

tumugi-plugin-google_drive provide config section named "google_drive" which can specified Google Drive autenticaion info.

#### Authenticate by client_email and private_key

```rb
Tumugi.config do |config|
  config.section("google_drive") do |section|
    section.project_id = "xxx"
    section.client_email = "yyy@yyy.iam.gserviceaccount.com"
    section.private_key = "zzz"
  end
end
```

#### Authenticate by JSON key file

```rb
Tumugi.configure do |config|
  config.section("google_drive") do |section|
    section.private_key_file = "/path/to/key.json"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tumugi/ttumugi-plugin-google_drive

## License

The gem is available as open source under the terms of the [Apache License
Version 2.0](http://www.apache.org/licenses/).
