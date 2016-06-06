task :task1 do
  requires :folder
  param :day, type: :time, auto_bind: true, required: true
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
  param_set :name, 'xyz'
end
