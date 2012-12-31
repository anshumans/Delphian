require_relative 'delphian_commands'

module DelphianConsole
  def self.run
    while (input = prompt) != DelphianCommands::Exit
      puts "console runnings"
    end

    puts "exiting ..."
  end

  def self.prompt
    puts "Enter command (type 'help' or '?' for list of commands):"
    $stdin.gets.strip
  end
end