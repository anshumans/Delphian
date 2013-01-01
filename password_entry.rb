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
end