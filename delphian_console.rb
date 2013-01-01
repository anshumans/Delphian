require_relative 'delphian_commands'
require 'stringio'

class DelphianConsole
  def run
    while (input = prompt_command) != DelphianCommands::Exit
      handle(input)
    end

    puts "exiting ..."
  end

  def prompt_command
    puts "Enter command (type 'help' for list of commands):"
    STDIN.gets.strip
  end

  def get_passphrase
    puts "What is your passphrase?"
    system "stty -echo"
    key = STDIN.gets.chomp
    system "stty echo"
    return Crypt::Blowfish.new(key)
  end

  def handle(input)
    case input
    when DelphianCommands::Help
      print_help
    when DelphianCommands::Load
      load_encrypted_file
    end
  end

  def print_help
    puts <<END_OF_BODY


#{DelphianCommands::Exit}        exit interactive session
#{DelphianCommands::Load}        load encrypted password file
#{DelphianCommands::Save}        save changes to an encrypted file
#{DelphianCommands::Close}        close loaded password file


END_OF_BODY
  end

  def load_encrypted_file
    puts "Enter encrypted file to load: "
    filename = File.expand_path(STDIN.gets.chomp)

    unless File.file?(filename)
      puts "#{filename} doesn't exist"
      return
    end

    @password_file = File.new(filename, 'rb')
    raw_decryption = StringIO.new
    @blowfish = get_passphrase

    @blowfish.decrypt_stream(@password_file, raw_decryption)
    puts "\nPassword File:\n"
    puts raw_decryption.string
    
  end
end