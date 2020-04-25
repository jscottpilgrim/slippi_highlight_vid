def get_file_list(dir)
    filenames = []

    Dir.foreach(dir) do |filename|
        next if filename =="." or filename == ".."
        
        if File.directory? filename
            next_level_files = get_file_list(filename)
            next_level_files.each { |f| filenames << "#{filename}/#{f}" }
        else
            filenames << filename
        end
    end

    return filenames
end

filenames = get_file_list Dir.pwd

filenames.shuffle!

File.open("shuffled_list.txt", "w") do |f|
    filenames.each { |filename| f.puts("file '#{filename}'")}
end