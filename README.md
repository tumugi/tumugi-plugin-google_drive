[![Build Status](https://travis-ci.org/tumugi/tumugi-plugin-google_drive.svg?branch=master)](https://travis-ci.org/tumugi/tumugi-plugin-google_drive) [![Code Climate](https://codeclimate.com/github/tumugi/tumugi-plugin-google_drive/badges/gpa.svg)](https://codeclimate.com/github/tumugi/tumugi-plugin-google_drive) [![Coverage Status](https://coveralls.io/repos/github/tumugi/tumugi-plugin-google_drive/badge.svg?branch=master)](https://coveralls.io/github/tumugi/tumugi-plugin-google_drive?branch=master) [![Gem Version](https://badge.fury.io/rb/tumugi-plugin-google_drive.svg)](https://badge.fury.io/rb/tumugi-plugin-google_drive)

# Google Drive plugin for [tumugi](https://github.com/tumugi/tumugi)

tumugi-plugin-google_drive is a plugin for integrate [Google Drive](https://www.google.com/intl/en/drive/) and [tumugi](https://github.com/tumugi/tumugi).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tumugi-plugin-google_drive'
```

And then execute `bundle install`

## Target

### Tumugi::Plugin::GoogleDriveFileTarget

`GoogleDriveFileTarget` represents file on Googl Drive.

#### Parameters

| name      | type                   | required? | default | description         |
|-----------|------------------------|-----------|---------|---------------------|
| name      | string                 | required  |         | Filename            |
| file_id   | string                 | optional  |         | File ID             |
| parents   | string or string array | optional  |         | Parent folder ID(s) |
| mime_type | string                 | optional  |         | MIME type of file |

`mime_type` is specifiy default mime_type value for `GoogleDriveFileTarget#open(mode="r", mime_type: @mime_type, &block)` method.

#### Examples

##### Create Google Drive file in folder named `xyz`, which content is "done"

```rb
task :task1 do
  param :day, type: :time, auto_bind: true, required: true

  output do
    target(:google_drive_file,
            name: "test_#{day.strftime('%Y%m%d')}.txt",
            parents: "xyz")
  end

  run do
    log "task1#run"
    output.open("w") {|f| f.puts("done") }
  end
end
```

##### Upload CSV file and convert it to Google Sheets file

```rb
task :task1 do
  param :day, type: :time, auto_bind: true, required: true

  output do
    target(:google_drive_file,
            name: "test_#{day.strftime('%Y%m%d')}.csv",
            mime_type: "application/vnd.google-apps.spreadsheet")
  end

  run do
    log "task1#run"
    output.open("w") {|f| f.puts("header1,header2"); f.puts("value1,value2") }
    # You can also specify mime_type by argument of open method.
    # output.open("w", mime_type: "application/vnd.google-apps.spreadsheet") { ... }
  end
end
```

### Tumugi::Plugin::GoogleDriveFolderTarget

`GoogleDriveFolderTarget` represents folder on Googl Drive.

#### Parameters

| name      | type                   | required? | default | description         |
|-----------|------------------------|-----------|---------|---------------------|
| name      | string                 | required  |         | Filename            |
| folder_id | string                 | optional  |         | Folder ID           |
| parents   | string or string array | optional  |         | Parent folder ID(s) |

## Task

### Tumugi::Plugin::GoogleDriveFolderTask

`GoogleDriveFolderTask` create a folder on Googl Drive.
Return value of `output` must be instance of `Tumugi::Plugin::GoogleDriveFolderTarget`

#### Parameters

| name      | type                   | required? | default | description         |
|-----------|------------------------|-----------|---------|---------------------|
| name      | string                 | required  |         | Filename            |
| folder_id | string                 | optional  |         | Folder ID           |
| parents   | string or string array | optional  |         | Parent folder ID(s) |

#### Examples

```rb
task :task1, type: :google_drive_folder do
  param :day, type: :time, auto_bind: true, required: true
  name { "test_#{day.strftime('%Y%m%d')}.txt" }
  parents "xyz"
end
```

Run this workflow via:

```sh
$ bundle exec tumugi run -f workflow.rb -p day:2016-07-01 task1
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

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake test` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tumugi/tumugi-plugin-google_drive

## License

The gem is available as open source under the terms of the [Apache License
Version 2.0](http://www.apache.org/licenses/).
