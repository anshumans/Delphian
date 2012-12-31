require_relative 'delphian_commands'

class DelphianConsole
  def run
    while (input = prompt) != DelphianCommands::Exit
      handle(input)
    end

    puts "exiting ..."
  end

  def prompt
    puts "Enter command (type 'help' for list of commands):"
    $stdin.gets.strip
  end

  def handle(input)
    case input
    when DelphianCommands::Help
      print_help
    end
  end

  def print_help
    puts <<END_OF_BODY


#{DelphianCommands::Exit}        exit interactive session


END_OF_BODY
  end
end