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
      @players = @@db_players.map { |player| player['lor'] }
      @elo_points = @@db_players.map { |player| player['elo'].to_s }
      @game_scores = Array.new(@@dim) { Array.new(@@dim) }
      @player_games = []
      @total_scores = []
      @player_places = []
      @berger_coefs = []
      @buffer = ''

      # Players who abandoned tournament
      @players_retired = ['uroboros', 'LongLiveUbuntu']

      # Correlate the player with his number
      @player_numbers = {}
      @players.each_with_index { |player, i| @player_numbers[player] = i }

      fill_results
      calculate
      results_to_s

      # Remove retired players from the tournament (seppuku)
      @players_retired.each do |player|
        num = @player_numbers[player]
        @players[num] = "<del>#{player}</del>"
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
      @game_scores.each do |row|
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
      end

      calculate_berger

      player_data = []
      @@dim.times do |i|
        player_data << { :number => i,
                         :total => @total_scores[i],
                         :berger => @berger_coefs[i] }
      end

      # Sort players in the reverse order to Berger coefficient
      player_data.sort! { |x,y| y[:berger] <=> x[:berger] }

      # Sort players in the reverse order to total score by the bubble
      # sorting, keeping the order of Berger coefficients for equal
      # total scores
      (@@dim - 1).times do |i|
        (@@dim - 2).downto(i) do |j|
          if player_data[j][:total] < player_data[j+1][:total]
            data = player_data[j]
            player_data[j] = player_data[j+1]
            player_data[j+1] = data
          end
        end
      end

      player_data.each_with_index do |data, i|
        @player_places[data[:number]] = (i + 1).to_s
      end
    end

    def calculate_berger
      @berger_coefs = @game_scores.map do |row|
        berger = 0.0
        row.each_with_index do |score, i|
          berger += score * @total_scores[i] unless score.nil?
        end
        berger
      end
    end

    def results_to_s
      @game_scores.map! { |row| row.map { |cell| stylize_score cell } }
      @total_scores.map! { |score| stylize_score score }
      @berger_coefs.map! { |coef| coef.to_s }
    end

    # Replace the fractional part `0.5' by ½
    def stylize_score score
      return '' if score.nil?
      frac = score.to_s.split '.'
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

      @@dim.times do |i|
        @buffer << "      <th>" << (i + 1).to_s << "</th>\n"
      end

      @buffer << "      <th>Игры</th>\n"
      @buffer << "      <th>Очки</th>\n"
      @buffer << "      <th>Место</th>\n"
      @buffer << "      <th>Бергер</th>\n"
      @buffer << "    </tr>\n"
      @buffer << "  </thead>\n"
      @buffer << "  <tbody>\n"

      @@dim.times do |i|

        @buffer << "    <tr class=\"place-" << @player_places[i] << "\">\n"
        @buffer << "      <td class=\"number\">" << (i + 1).to_s << "</td>\n"
        @buffer << "      <td class=\"player\"><strong>" << @players[i] << "</strong></td>\n"
        @buffer << "      <td class=\"elo\">" << @elo_points[i] << "</td>\n"

        @@dim.times do |j|
          unless j == i
            @buffer << "      <td class=\"score\">" << @game_scores[i][j] << "</td>\n"
          else
            @buffer << "      <td class=\"diagonal\"></td>\n"
          end
        end

        @buffer << "      <td class=\"games\">" << @player_games[i] << "</td>\n"
        @buffer << "      <td class=\"total\">" << @total_scores[i] << "</td>\n"
        @buffer << "      <td class=\"place\">" << @player_places[i] << "</td>\n"
        @buffer << "      <td class=\"berger\">" << @berger_coefs[i] << "</td>\n"
        @buffer << "    </tr>\n"
      end

      @buffer << "  </tbody>\n"
      @buffer << "</table>\n"
      @buffer << "* Средний elo на 13.09.2013 3.00 МСК"
      @buffer
    end

  end
end
