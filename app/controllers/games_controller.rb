
class GamesController < ApplicationController


  def game
    @grid = generate_grid(9)
    @start_time = Time.now
    # raise

    # SESSION VARIABLES
    session[:user_count] = session[:user_count] ? session[:user_count] + 1 : 1 #initialize with 1 if doesnt exist
    session[:total_score] = session[:total_score] ? session[:total_score] : 0 #initialize with 0 if doesnt exist
    # raise
  end

  def score
    @user_count = session[:user_count]
    @attempt = params[:attempt]
    @end_time = Time.now
    @grid = params[:grid].chars
    @start_time = Time.parse(params[:start_time])
    # compute the game results
    result = run_game(@attempt, @grid, @start_time, @end_time)
    @time = result[:time].round(2)
    @score = result[:score].round(2)
    @message = result[:message]

    session[:total_score] += @score
    @total_score = session[:total_score]
  end

  def reset
    session[:total_score] = 0
    session[:user_count] = nil
    redirect_to :game
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = (0...grid_size).map { (65 + rand(26)).chr }
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # initialise variables
    time = end_time.to_f - start_time.to_f
    # CALL THE METHODS
    # IS IT ENGLISH? ==> t/f
    english = find_our_word(attempt)
    # DOES IT MATCH OUR GRID? ==> t/f
    grid_match = grid_match(attempt, grid)
    # WHAT'S THE SCORE?
    score = game_score(attempt, time, english, grid_match)
    # CREATE A CUSTOM MESSAGE
    message = game_messages(score, grid_match)
    # CREATE HASH to return to interface
    result = {
      time: time,
      score: score,
      message: message
    }
    return result
  end

  def grid_match(attempt, grid)
    # MATCH GRID f WITH ATTEMPT f
    #GRID Frequency
    grid_f = Hash.new(0)
    grid.each { |letter| grid_f[letter] += 1 }

    #ATTEMPT Frequency
    attempt = attempt.upcase.chars
    attempt_f = Hash.new(0)
    attempt.each { |letter| attempt_f[letter] += 1 }

    #MATCH ON HASH VALUES
    attempt_f.each do |letter, _value|
      if attempt_f[letter] <= grid_f[letter]
        true
      else
        return false
      end
    end
    return true
  end

  def find_our_word(attempt)
    attempt = attempt
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    serialized_json = open(url).read
    hash_attempt = JSON.parse(serialized_json)
    found = hash_attempt["found"]
    return found
  end

  def game_score(attempt, time, english, grid_match)
    if grid_match
      if english
        score = (attempt.length.to_f)*10 / time.to_f
      else
        score = 0
      end
    else
      score = 0
    end
    return score
  end

  def game_messages(score, grid_match = true)
    if grid_match
      if score.zero?
        message = "not an english word"
      else
        message = "Well Done!"
      end
    else
      message = "not in the grid"
    end
    return message
  end



end
