task :task1 do
  param :day, type: :time, auto_bind: true, required: true
  requires :folder

  output do
    target(:google_drive_file,
          name: "test_#{day.strftime('%Y%m%d')}.txt",
          parents: input.folder_id)
  end

  run do
    log 'task1#run'
    output.open('w') {|f| f.puts('done') }
  end
end

task :folder, type: :google_drive_folder do
  name 'xyz'
end
