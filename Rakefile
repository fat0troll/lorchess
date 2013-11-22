# -*- coding: utf-8 -*-
require 'rake'

# The year and title of tournament
@year = '2013'
@tournament ='4-knockout'

require 'yaml'
file_dir = File.dirname(__FILE__)
yaml_file = File.expand_path("#{@year}/#{@tournament}/players.yml", file_dir)
@config = YAML.load_file yaml_file

# Sort players in numerical order
@config.sort! { |x,y| x['number'] <=> y['number'] }

# Associate a 'lichess' nickname with player's name
@player_lichess = {}
@config.each do |player|
  lichess = player['lichess']
  @player_lichess[lichess] = player['lor']
end

# Fix a player name in PGN
def fix_player color, name
  str = File.open('temp.pgn', 'r') { |f| f.read }
  player_regex = Regexp.new "^\\[#{color.capitalize} \".*\"\\]$"
  parts = str.partition player_regex
  File.open('temp.pgn', 'w+') do |f|
    f.write(parts[0] + "[#{color.capitalize} \"#{name}\"]" + parts[2])
  end
  puts "The 'lichess' name '#{name}' of #{color} player incorporated into PGN"
end

# Fix the game date in PGN: YYYY-MM-DD -> YYYY.MM.DD
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

# Returns the 'lichess' name of player to be corrected
def choose_name
  print "Would you like to correct the name? > "
  answer = $stdin.gets.chomp
  if ['Yes', 'yes', 'Y', 'y'].include? answer
    @config.each do |player|
      puts "%2.0f. %s" % [ player['number'], player['lor'] ]
    end

    print "Put the player's number > "
    num = Integer $stdin.gets.chomp
    @config[num-1]['lichess']
  else
    abort
  end
end

# Returns the directory name to put PGN file in
def pgn_dir
  str = File.open('temp.pgn', 'r') { |f| f.read }

  date = str.scan(/^\[Date \"(.*)\"\]$/)[0][0]
  date.gsub! '.', '-'
  white_lichess = str.scan(/^\[White \"(.*)\"\]$/)[0][0]
  white = @player_lichess[white_lichess]
  black_lichess = str.scan(/^\[Black \"(.*)\"\]$/)[0][0]
  black = @player_lichess[black_lichess]

  unless white
    puts "Could not recognize white player '#{white_lichess}'"
    name = choose_name
    fix_player 'white', name
    white = @player_lichess[name]
  end
  unless black
    puts "Could not recognize black player '#{black_lichess}'"
    name = choose_name
    fix_player 'black', name
    black = @player_lichess[name]
  end

  date + '-' + white + '-vs-' + black
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

    # Change `1' -> `01' and so on
    tour = "%02g" % ENV['tour']

    dir = "#{@year}/#{@tournament}/tours/#{tour}/" + pgn_dir
    if Dir.exists? dir
      puts "PGN directory exists"
    else
      puts "Directory '#{dir}' does not exist"
      print "Create the directory? > "
      answer = $stdin.gets.chomp
      if ['Yes', 'yes', 'Y', 'y'].include? answer
        FileUtils.mkdir_p dir
      else
        abort "PGN directory wasn't created"
      end
    end
    dest = dir + '/' + pgn_file(dir)
    puts "Moving PGN file to '#{dest}'"
    FileUtils.mv('temp.pgn', dest)
  end

  desc "Download and move PGN file at once"
  task :create do
    Rake::Task['pgn:get'].invoke
    Rake::Task['pgn:mv'].invoke
  end
end
