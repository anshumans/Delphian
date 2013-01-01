class PasswordEntry

  attr_accessor :name
  attr_accessor :url
  attr_accessor :username
  attr_accessor :password

  def initialize(line)
    items = line.split(',')
    self.name = items[0]
    self.url = items[1]
    self.username = items[2]
    self.password = items[3]
  end

  def to_s
    "#{name}\t#{url}\t#{username}\t#{password}"
  end

  def contains(search_term)
    return self.name.downcase.include?(search_term.downcase) || self.url.downcase.include?(search_term.downcase) || 
    self.username.downcase.include?(search_term.downcase) || self.password.downcase.include?(search_term.downcase)
  end
end