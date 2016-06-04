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
