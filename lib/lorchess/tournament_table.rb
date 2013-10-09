# -*- coding: utf-8 -*-

module LORChess
  class TournamentTable

    require 'yaml'

    dir = File.dirname(__FILE__)
    players_yaml = File.expand_path('../../autumn2013/players.yml', dir)
    @@db_players = YAML.load_file players_yaml
    results_yaml = File.expand_path('../../autumn2013/results.yml', dir)
    @@db_results = YAML.load_file results_yaml

    @@dim = @@db_players.length

    # Sort players in numerical order
    @@db_players.sort! { |x,y| x['number'] <=> y['number'] }

    def initialize
      @players = []
      @elo_points = []
      @game_scores = Array.new(@@dim) { Array.new(@@dim) }
      @player_games = []
      @total_scores = []
      @player_places = []
      @berger_coefs = []
      @buffer = ''

      @@db_players.each do |player|
        @players << player['lor']
        @elo_points << player['elo'].to_s
      end

      # Correlate the player with his number
      @player_numbers = {}
      @players.each_with_index { |player, num| @player_numbers[player] = num }

      fill_results
      calculate
      stylize_table

      # Clean the vacancy place
      num = @player_numbers['Kasparov']
      if num
        @players[num] = '<em style="font-weight:normal">отсутствует</em>'
        @elo_points[num] = '1200'
      end
    end

    def fill_results
      @@db_results.each do |tour|
        tour['games'].each do |game|
          import game
        end
      end
    end

    def import game
      num_white = @player_numbers[game['white']]
      num_black = @player_numbers[game['black']]
      score = game['result'].split ':'

      @game_scores[num_white][num_black] = score[0].to_f
      @game_scores[num_black][num_white] = score[1].to_f
    end

    def calculate
      player_scores = []

      @game_scores.each_with_index do |row, num|
        games = 0
        sum = 0.0
        row.each do |score|
          unless score.nil?
            games += 1
            sum += score
          end
        end
        @player_games << games.to_s
        @total_scores << sum
        player_scores << { :number => num, :total => sum }
      end

      # Sort players in the reverse order to total score
      player_scores.sort! { |x,y| y[:total] <=> x[:total] }

      player_scores.each_with_index do |data, num|
        @player_places[data[:number]] = (num + 1).to_s
      end
    end

    def stylize_table
      for row in 0..(@@dim - 1)
        for cell in 0..(@@dim - 1)
          @game_scores[row][cell] = stylize_score @game_scores[row][cell]
        end

        @total_scores[row] = stylize_score @total_scores[row]
      end
    end

    # Replace the fractional part `0.5' by ½
    def stylize_score score
      frac = score.to_s.split '.'
      return '' if frac[0].nil?
      unless frac[0] == '0'
        str = frac[0]
        str += '½' if frac[1] == '5'
      else
        str = (frac[1] == '5') ? '½' : '0'
      end
      str
    end

    def to_html

      @buffer << "<table class=\"table table-bordered tournament\">\n"
      @buffer << "  <caption><strong>LOR Chess : Осень-2013</strong><caption>\n"
      @buffer << "  <thead>\n"
      @buffer << "    <tr>\n"
      @buffer << "      <th>№</th>\n"
      @buffer << "      <th>Участник</th>\n"
      @buffer << "      <th>elo*</th>\n"

      for cell in 0..(@@dim - 1)
        @buffer << "      <th>" << (cell + 1).to_s << "</th>\n"
      end

      @buffer << "      <th>Игры</th>\n"
      @buffer << "      <th>Очки</th>\n"
      @buffer << "      <th>Место</th>\n"
      @buffer << "    </tr>\n"
      @buffer << "  </thead>\n"
      @buffer << "  <tbody>\n"

      for row in 0..(@@dim - 1)

        @buffer << "    <tr class=\"place-" << @player_places[row] << "\">\n"
        @buffer << "      <td class=\"number\">" << (row + 1).to_s << "</td>\n"
        @buffer << "      <td class=\"player\"><strong>" << @players[row] << "</strong></td>\n"
        @buffer << "      <td class=\"elo\">" << @elo_points[row] << "</td>\n"

        for cell in 0..(@@dim - 1)
          unless cell == row
            @buffer << "      <td class=\"score\">" << @game_scores[row][cell] << "</td>\n"
          else
            @buffer << "      <td class=\"diagonal\"></td>\n"
          end
        end

        @buffer << "      <td class=\"games\">" << @player_games[row] << "</td>\n"
        @buffer << "      <td class=\"total\">" << @total_scores[row] << "</td>\n"
        @buffer << "      <td class=\"place\">" << @player_places[row] << "</td>\n"
        @buffer << "    </tr>\n"
      end

      @buffer << "  </tbody>\n"
      @buffer << "</table>\n"
      @buffer << "* Средний elo на 13.09.2013 3.00 МСК"
      @buffer
    end

  end
end
