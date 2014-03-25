# -*- coding: utf-8 -*-

module LORChess
  class RoundRobinTable

    require 'yaml'

    DATADIR = '2014/1-tabiyas'
    ROUNDS = 2

    dir = File.dirname(__FILE__)
    players_yaml = File.expand_path("../../#{DATADIR}/players.yml", dir)
    @@db_players = YAML.load_file players_yaml
    results_yaml = File.expand_path("../../#{DATADIR}/results.yml", dir)
    @@db_results = YAML.load_file results_yaml

    @@dim = @@db_players.length
    @@rounds = ROUNDS || 1

    # Sort players in numerical order
    @@db_players.sort! { |x,y| x['number'] <=> y['number'] }

    def initialize
      @players = @@db_players.map { |player| player['lor'] }
      @elo_points = @@db_players.map { |player| player['elo'].to_s }
      @game_scores = Array.new(@@rounds) {
        Array.new(@@dim) { Array.new(@@dim) }
      }
      @player_games = Array.new(@@dim, 0)
      @total_scores = Array.new(@@dim, 0.0)
      @player_places = Array.new(@@dim)
      @berger_coefs = Array.new(@@dim, 0.0)
      @buffer = ''

      # Players withdrew from tournament
      @players_withdrew = @@db_players
        .select { |player| player['status'] == 'withdrew' }
        .map { |player| player['lor'] }

      # Correlate the player with his number
      @player_numbers = {}
      @players.each_with_index { |player, i| @player_numbers[player] = i }

      fill_results
      calculate
      results_to_s

      # Withdraw players from tournament (seppuku)
      @players_withdrew.each do |player|
        num = @player_numbers[player]
        @players[num] = "<del>#{player}</del>"
      end
    end

    def fill_results
      @@db_results.each do |tour|
        if tour['games']
          # zero-based round
          round = (tour['number'] - 1).div(@@dim - 1)

          tour['games'].each do |game|
            import game, round
          end
        end
      end
    end

    def import game, round
      num_white = @player_numbers[game['white']]
      num_black = @player_numbers[game['black']]
      score = game['result'].split ':'

      @game_scores[round][num_white][num_black] = score[0].to_f
      @game_scores[round][num_black][num_white] = score[1].to_f
    end

    def calculate
      @game_scores.each do |round|
        round.each_with_index do |row, index|
          games = 0
          sum = 0.0
          row.each do |score|
            unless score.nil?
              games += 1
              sum += score
            end
          end
          @player_games[index] += games
          @total_scores[index] += sum
        end
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
      @game_scores.each do |round|
        round.each_with_index do |row, index|
          berger = 0.0
          row.each_with_index do |score, i|
            berger += score * @total_scores[i] unless score.nil?
          end
          @berger_coefs[index] += berger
        end
      end
    end

    def results_to_s
      @game_scores.map! do |round|
        round.map do |row|
          row.map { |cell| stylize_score cell }
        end
      end
      @player_games.map! { |num| num.to_s }
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

      @buffer << "<table class=\"table tournament tablesorter\">\n"
      @buffer << "  <caption><strong>Таблица результатов</strong><caption>\n"
      @buffer << "  <thead>\n"
      @buffer << "    <tr>\n"
      @buffer << "      <th>№</th>\n"
      @buffer << "      <th>Участник</th>\n"
      @buffer << "      <th>elo*</th>\n"

      @@dim.times do |i|
        @buffer << "      <th class=\"opponent\" colspan=\"#{@@rounds.to_s}\">#{(i + 1).to_s}</th>\n"
      end

      @buffer << "      <th>Игры</th>\n"
      @buffer << "      <th>Очки</th>\n"
      @buffer << "      <th>Место</th>\n"
      @buffer << "      <th>Бергер</th>\n"
      @buffer << "    </tr>\n"
      @buffer << "  </thead>\n"
      @buffer << "  <tfoot>\n"
      @buffer << "    <tr>\n"
      @buffer << "      <td colspan=\"#{(@@dim * @@rounds + 7).to_s}\">* Средний elo на начало турнира</td>\n"
      @buffer << "    </tr>\n"
      @buffer << "  </tfoot>\n"
      @buffer << "  <tbody>\n"

      @@dim.times do |i|

        @buffer << "    <tr class=\"place-#{@player_places[i]}\">\n"
        @buffer << "      <td class=\"number\">#{(i + 1).to_s}</td>\n"
        @buffer << "      <td class=\"player\"><strong>#{@players[i]}</strong></td>\n"
        @buffer << "      <td class=\"elo\">#{@elo_points[i]}</td>\n"

        @@dim.times do |j|
          unless j == i
            @@rounds.times do |round|
              @buffer << "      <td class=\"score\">#{@game_scores[round][i][j]}</td>\n"
            end
          else
            @buffer << "      <td class=\"diagonal\"></td>\n" * @@rounds
          end
        end

        @buffer << "      <td class=\"games\">#{@player_games[i]}</td>\n"
        @buffer << "      <td class=\"total\">#{@total_scores[i]}</td>\n"
        @buffer << "      <td class=\"place\">#{@player_places[i]}</td>\n"
        @buffer << "      <td class=\"berger\">#{@berger_coefs[i]}</td>\n"
        @buffer << "    </tr>\n"
      end

      @buffer << "  </tbody>\n"
      @buffer << "</table>\n"
      @buffer
    end

  end
end
