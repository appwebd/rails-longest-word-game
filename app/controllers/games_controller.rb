class GamesController < ApplicationController
  def new
    @letter = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @attempt = params[:word]

    @compute = run_game(@attempt, @letter, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  # runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
  def run_game(attempt, grid, start_time, end_time)

    @result = { time: end_time - start_time }

    type = get_type_error(attempt, grid)
    message = get_message(type)
    score = 0
    score = compute_score(attempt, result[:time]) if type == 3

    @result[:score] = score
    @result[:message] = message

    @result

  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  # # Included word | english word
  # 0      0             0
  # 1      0             1
  # 2      1             0
  # 3      1             1
  def get_type_error(attempt, grid)
    type = 0
    type = 1 if english_word?(attempt)
    type = 2 + type if included_word?(attempt.upcase, grid)
    type
  end

  def get_message(type)
    case type
    when 0 then 'not in the grid and not an english word'
    when 1 then 'not in the grid and is a english word'
    when 2 then 'not an english word'
    when 3 then 'well done'
    else
      'your type value is out of range [0-3]'
    end
  end

  def included_word?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end
end
