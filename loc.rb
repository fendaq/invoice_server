ruby_files = Dir.glob('modules/**/*.rb') + ['app.rb']
view_files = Dir.glob('views/**/*')

files = { ruby: ruby_files, view: view_files }

files.map do |fg, files|
  o = 0 # Number of files
  n = 0 # Number of lines of code
  m = 0 # Number of lines of comments
  files.each do |f|
    next if FileTest.directory?(f)
    o += 1
    i = 0
    lines = []
    File.new(f).each_line do |line|
      if line.strip[0] == '#'
        m += 1
        next
      end
      lines << line
      i += 1
    end
    n += i
  end
  puts "#{fg}:"
  puts "  #{o.to_s} files."
  puts "  #{n.to_s} lines of code."
  puts "  #{(n.to_f/o.to_f).round(2)} LOC/file."
  puts "  #{m.to_s} lines of comments."
end
