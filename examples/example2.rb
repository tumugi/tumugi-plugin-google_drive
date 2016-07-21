task :task1 do
  param :day, type: :time, auto_bind: true, required: true
  param :seed, type: :string, auto_bind: true, required: true
  requires :folder

  output do
    target(:google_drive_file,
          name: "test_#{day.strftime('%Y%m%d%H%M')}_#{seed}.txt",
          parents: input.folder_id)
  end

  run do
    log "task1#run"
    output.open("w") {|f| f.puts("done") }
  end
end

task :folder, type: :google_drive_folder do
  name "existing_folder"
end
