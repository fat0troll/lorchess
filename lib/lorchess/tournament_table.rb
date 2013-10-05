# -*- coding: utf-8 -*-

module LORChess
  class TournamentTable

    require 'yaml'

    dir = File.dirname(__FILE__)
    players_yaml = File.expand_path('../../autumn2013/players.yml', dir)
    @@db_players = YAML.load_file players_yaml
    results_yaml = File.expand_path('../../autumn2013/results.yml', dir)
    @@db_results = YAML.load_file results_yaml

    # Sort players in numerical order
    @@db_players.sort! { |x,y| x['number'] <=> y['number'] }

    def initialize
      @players = []
      @elo_list = []
      @dim = @@db_players.length
      @results = Array.new(@dim) { Array.new(@dim, '') }
      @player_score = []
      @buffer = ''

      @@db_players.each do |player|
        @players << player['lor']
        @elo_list << player['elo'].to_s
      end

      # Correlate the player with his position
      @player_pos = {}
      @players.each_with_index { |player, pos| @player_pos[player] = pos }

      fill
      calculate
      stylize_table

      # Clean the vacancy place
      index = @player_pos['Kasparov']
      if index
        @players[index] = '<em style="font-weight:normal">отсутствует</em>'
        @elo_list[index] = '1200'
      end
    end

    def fill
      @@db_results.each do |tour|
        tour['games'].each do |game|
          import game
        end
      end
    end

    def import game
      pos_white = @player_pos[game['white']]
      pos_black = @player_pos[game['black']]
      score = game['result'].split ':'

      @results[pos_white][pos_black] = score[0]
      @results[pos_black][pos_white] = score[1]
    end

    def calculate
      @results.each do |row|
        sum = 0.0
        row.each { |score| sum += score.to_f }
        @player_score << sum.to_s
      end
    end

    def stylize_table
      for row in 0..(@dim-1)
        for cell in 0..(@dim-1)
          @results[row][cell] = stylize_score @results[row][cell]
        end

        @player_score[row] = stylize_score @player_score[row]
      end
    end

    # Replace the fractional part `0.5' by ½
    def stylize_score score
      frac = score.split '.'
      return '' if frac[0].nil?
      unless frac[0] == '0'
        score = frac[0]
        score += '½' if frac[1] == '5'
      else
        score = (frac[1] == '5') ? '½' : '0'
      end
      score
    end

    def to_html

      @buffer << "<table class=\"table table-bordered tournament\">\n"
      @buffer << "  <caption><strong>LOR Chess : Осень-2013</strong><caption>\n"
      @buffer << "  <thead>\n"
      @buffer << "    <tr>\n"
      @buffer << "      <th></th>\n"
      @buffer << "      <th>Участник</th>\n"
      @buffer << "      <th>elo*</th>\n"

      for cell in 0..(@dim-1)
        @buffer << "      <th>" << (cell+1).to_s << "</th>\n"
      end

      @buffer << "      <th>Очки</th>\n"
      @buffer << "      <th>Место</th>\n"
      @buffer << "    </tr>\n"
      @buffer << "  </thead>\n"
      @buffer << "  <tbody>\n"

      for row in 0..(@dim-1)

        @buffer << "    <tr>\n"
        @buffer << "      <td>" << (row+1).to_s << "</td>\n"
        @buffer << "      <td><strong>" << @players[row] << "</strong></td>\n"
        @buffer << "      <td>" << @elo_list[row] << "</td>\n"

        for cell in 0..(@dim-1)
          unless cell == row
            @buffer << "      <td class=\"table-cell\">" << @results[row][cell] << "</td>\n"
          else
            @buffer << "      <td class=\"table-cell-diag\"></td>\n"
          end
        end

        @buffer << "      <td>" << @player_score[row] << "</td>\n"
        @buffer << "      <td></td>\n"
        @buffer << "    </tr>\n"
      end

      @buffer << "  </tbody>\n"
      @buffer << "</table>\n"
      @buffer << "* Средний elo на 13.09.2013 3.00 МСК"
      @buffer
    end

  end
end
