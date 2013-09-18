# -*- coding: utf-8 -*-
require 'rake'
tournament='autumn2013'

# Fix the game date in PNG: YYYY-MM-DD -> YYYY.MM.DD
def fix_date
  str = File.open('temp.pgn', 'r') { |f| f.read }
  parts = str.partition /^\[Date \"\d{4}-\d{2}-\d{2}\"\]$/
  if parts[1].empty?
    puts "The game date is already correct"
  else
    parts[1].gsub! '-', '.'
    File.open('temp.pgn', 'w+') do |f|
      f.write(parts[0] + parts[1] + parts[2])
    end
    puts "The game date corrected"
  end
end

# Return the directory name to put PGN file in
def pgn_dir
  str = File.open('temp.pgn', 'r') { |f| f.read }

  date = str.scan(/^\[Date \"(.*)\"\]$/)[0][0]
  date.gsub! '-', '.' # if date has not been corrected
  white = str.scan(/^\[White \"(.*)\"\]$/)[0][0]
  black = str.scan(/^\[Black \"(.*)\"\]$/)[0][0]

  dir = date + ' — ' + white + ' vs. ' + black
  return dir
end

# Return the file name to move PGN file to
def pgn_file dir
  file = (Dir.entries(dir).length - 1).to_s + '.pgn'
  if File.exists? (dir + '/' + file)
    abort "Something wrong: PGN file already exists"
  end
  file
end

namespace :pgn do
  desc "Parse a web page of lichess.org and save the PGN to temp file"
  task :get do |t, args|
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::HTML open ENV['url']
    link = doc.css('a.view_pgn_toggle').first
    pgn_url = 'http://lichess.org' + link['href']
    str = URI.parse(pgn_url).read
    File.open('temp.pgn', 'w') { |f| f.write str }
    fix_date # fix the game date
  end

  desc "Move PNG into the directory of destination"
  task :mv do
    require 'fileutils'

    tour = ('0' + ENV['tour'])[-2..-1] # change `1' -> `01' and so on
    dir = tournament + '/tour_' + tour + '/' + pgn_dir
    if Dir.exists? dir
      puts "PGN directory exists"
    else
      puts "Directory \"#{dir.shellescape}\" doesn't exist"
      print "Create the directory? "
      answer = $stdin.gets.chomp
      if ['Yes', 'yes', 'y'].include? answer
        FileUtils.mkdir_p dir
      else
        abort "PGN directory wasn't created"
      end
    end
    dest = dir + '/' + pgn_file(dir)
    puts "Moving PGN file to \"#{dest.shellescape}\""
    FileUtils.mv('temp.pgn', dest)
  end

  desc "Download and move PGN file at once"
  task :create do
    Rake::Task['pgn:get'].invoke
    Rake::Task['pgn:mv'].invoke
  end
end
