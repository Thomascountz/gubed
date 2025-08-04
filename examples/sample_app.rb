class SampleApp
  def initialize
    @users = []
    binding.pry # Debug initialization
  end

  def add_user(name, email)
    user = { name: name, email: email }
    # binding.irb # Commented out debug point
    @users << user
    debugger # Check user addition
  end

  def find_user(email)
    result = @users.find { |user| user[:email] == email }
    binding.break if result.nil?
    result
  end

  def process_users
    @users.each do |user|
      puts "Processing #{user[:name]}"
      byebug # Debug each user processing
    end
  end
end
