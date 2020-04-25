timestamp_file = ARGV[0]

#path to ffmpeg program
#add surrounding quotes if path contains spaces
#default is ffmpeg
ffmpeg_path = ffmpeg

base_path = Dir.pwd
dot_i = timestamp_file.index(".")
dir_name = timestamp_file[0...dot_i]
dir_path = "#{base_path}/#{dir_name}"
unless Dir.exist? dir_path
    Dir.mkdir dir_path
end

require 'csv'
table = CSV.read(timestamp_file)

#name of full video may be first line
input_file = table[0][0].strip
character_name = ""

for i in 1...table.size
    if table[i].size < 1
        #skip blank line
        next
    elsif table[i][0][0] == "#"
        #skip comment lines
        next
    elsif table[i].size == 1
        if table[i][0][-4] == "."
            #check for a file extension for new file to cut from
            input_file = table[i][0].strip
        else
            #character specific clips go in separate directories
            character_name = table[i][0].strip.capitalize

            #make sure character directory exists
            unless Dir.exist? "#{dir_path}/#{character_name}"
                Dir.mkdir "#{dir_path}/#{character_name}"
            end
        end
    else
        start_time = table[i][0].strip

        #convert to seconds
        colon_i = start_time.index(":")
        start_minute = start_time[0...colon_i]
        start_second = start_time[colon_i+1...start_time.length]
        start_time = start_minute.to_i * 60 + start_second.to_i
        #start half second early
        start_time -= 0.5

        end_time = table[i][1].strip
        #convert to seconds
        colon_i = end_time.index(":")
        end_minute = end_time[0...colon_i]
        end_second = end_time[colon_i+1...end_time.length]
        end_time = end_minute.to_i * 60 + end_second.to_i

        duration = end_time - start_time

        score = table[i][2].strip
        slash_i = score.index("/")
        score = score[0...slash_i]

        clip_name = table[i][3].strip
        clip_name.gsub!(" ", "_")

        #combine score and name for output file
        #change decimal point in score to dash
        if score[1] and score[1] == "."
            score[1] = "-"
        end
        output_file = "s#{score}_#{clip_name}.mp4"

        #call ffmpeg to cut clip
        #timestamp can also be in sexagesimal format
        #`#{ffmpeg_path} -i \"#{input_file}\" -ss 00:#{start_time} -to 00:#{end_time} -c:v copy -c:a copy \"#{dir_path}/#{character_name}/#{output_file}\"`

        #put seek time (ss) after input file for a slower conversion and audio desync but more accurate start
        # -an is added to remove audio since it is not synchronized with this method
        `#{ffmpeg_path} -i \"#{input_file}\" -ss #{start_time} -to #{end_time} -c:v copy -c:a copy -an \"#{dir_path}/#{character_name}/#{output_file}\"`

        #puts seek (ss) before input file for a very fast conversion and proper audio sync, but maintain empty frames from keyframe
        #`#{ffmpeg_path} -ss #{start_time} -t #{duration} -i \"#{input_file}\" -c copy \"#{dir_path}/#{character_name}/#{output_file}\"`

        #test
        #puts "#{ffmpeg_path} -i \"#{input_file}\" -ss 00:#{start_time} -to 00:#{end_time} -c:v copy -c:a copy \"#{dir_path}/#{character_name}/#{output_file}\""
        #puts "#{ffmpeg_path} -ss #{start_time} -t #{duration} -i \"#{input_file}\" -c copy \"#{dir_path}/#{character_name}/#{output_file}\""
    end
end