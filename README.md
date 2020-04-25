# Purpose
This is a combination of scripts I use in sequence in order to streamline the process of cutting clips from recorded gameplay of Super Smash Bros. Melee and then concatenating those clips into one highlight video.

# Requirements
- ffmpeg
- slp-parser-js

# Method
1. I use a modified version of schmooblidon's schlippi script (https://github.com/schmooblidon/schlippi) to extract cuts of gameplay from .slp replay files. My version of schlippi outputs multiple json files with only one clip per .slp file each in order to make the clips json file compatible with slippi r18.
2. Play the results of schlippi in slippi r18 and record the results with a screen capture program. (I use windows built in game capture utility).
3. Make note of the start and stop times for each clip in the video to cut, and record this in a csv file similar to the included example.csv.
Format:
`file_name`
`character_name`
`start_time, end_time, clip_rating, clip_title`
4. Run cut_clips.rb, passing as an argument the csv file from the previous step. `rb cut_clips.rb example.csv`
5. Run `rb shuffled_file_list.rb` to create a text file for ffmpeg to use in the next step.
6. Run `ffmpeg -f concat -i shuffled_list.txt -c copy concat_combos.mp4` to produce the final consolidated highlight video.