require 'yaml' 
 

#TODO : ability to save game, Ability to play again
# DIR NEW?
class Hangman
	attr_reader :old_games

	def initialize
		@old_games = get_games
		game_flow

	end

	def play_again
		puts "Do you want to play again? (yes/no)"
		input = gets.chomp.downcase
		until input == "yes" or input == "no"
		puts "Make sure you enter yes or no"
		input = gets.chomp.downcase			
		end
		if input == 'yes'
			game_flow
		else
			puts "Exiting!"
			exit
		end
	end

	def game_flow
		@old_games = get_games
		if @old_games

			game_names = @old_games.collect { |file| game = file.match(/\/([A-Za-z\-_]+)\.yaml/)[1] }

			puts "Found Saved Games!\n#{game_names}\nPlease choose a type a game name or type \"new\" to create a new game."
			input = gets.chomp.downcase

			until game_names.include?(input) or input == 'new'
				puts "Game not found, please enter another name or \"new\".\n #{game_names}"
				input = gets.chomp.downcase
			end

			if game_names.include?(input)
				load_file = File.read("saved/#{input}.yaml")
				obj = YAML::load(load_file)
				obj.loaded_game

			elsif input == 'new'
				Game.new(self)
			end

		else
			puts "No Games Found, creating a new game."
			Game.new(self)
		end
	end

	def get_games
		if Dir.exists? "saved"
			games = Dir.glob("saved/*.yaml")
		end
	end

end

class Game
	attr_reader :guesses

# initialize, load a word *done
	def initialize(hangman)
		@controller = hangman
		@num_guesses = 10
		@user_guesses = []

		word_file = File.readlines("5desk.txt")

		@word = word_file.sample.gsub(/\s+/, '').downcase

		while @word.length < 5 and @word.length > 13
			@word = @word_file.sample.gsub(/s+/, '')
		end
		puts "Game initialized!"
		puts (@word)
		play
	end
# get input -  guess letter (dcase), or save game
	def play
		processed = process_guesses(@user_guesses, @word)
		board = draw(processed)
		input = get_input
		@user_guesses << input
		@num_guesses -= 1
		result = game_over?
		if result[:over]
			puts "Game Over!\n#{result[:message]}"
			puts "Word was #{@word}"
			return @controller.play_again
		else
			return play
		end

	end
# get_input
	def get_input
		puts "What is your next guess?\n Guess must be one letter and not already be guessed\nType 'save' to save game."
		guess = gets.chomp.downcase
		result = check_guess(guess)
		until result[:correct]
			puts result[:message]
			guess = gets.chomp.downcase
			result = check_guess(guess)
		end
		if result[:save]
			return save_game
		end
		guess

	end

	def check_guess(guess)
		result = {correct: true, message: "Good to go!", save: false}
		if @user_guesses.rindex(guess)
			result[:correct] = false
			result[:message] = "Guess already exists. Please try again"
		elsif guess.length != 1 and guess != 'save'
			result[:correct] = false
			result[:message] = "You didn't guess exactly one letter! Please try again"
		elsif guess == 'save'
			result[:save] = true

		end
		result
	end

	def game_over?
		result = {over: false, message: "Keep Going"}
		if @word == process_guesses(@user_guesses, @word)
			result[:over] = true
			result[:message] = "You guessed correctly!"
		elsif @num_guesses < 1
			result[:over] = true
			result[:message] = "Ran out of guesses!"
		end
		result
	end

	def process_guesses(guesses, word)
		output = ''
		word.each_char do |letter|
			search = guesses.rindex(letter)
			if search
				output += letter
			else
				output += "_"
			end

		end
		output
	end
# draw "hangman"
	def draw(input)
		output = input.split.join(' ') + "\n Your guesses: #{@user_guesses}\n #{@num_guesses} left"
		puts output
	end

	def loaded_game
		puts "Game Loaded Sucessfully!"
		play
	end
	# save game check if dir exists blah blah *done
	def save_game
		puts "To save game please provide a game name. Please only use letters, numbers and underscores"
		input = gets.chomp.downcase
		valid = input.index(/[^\d,\w,_]/)
		until !valid
			puts "Please enter a valid name"
			input = gets.chomp.downcase	
			valid = input.index(/[^\d+,\w+, _+]/)			
		end
		puts "Saving #{input}"
		yaml = YAML::dump(self)
		if !Dir.exists?("saved")
			Dir.mkdir("saved") 
		end
		save_file = File.open("saved/#{input}.yaml", 'w')
		save_file.write(yaml)
		save_file.close
		puts "Game Saved!"
		exit
	end
end

Hangman.new