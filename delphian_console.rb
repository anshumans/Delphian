require_relative 'delphian_commands'
require_relative 'password_entry'
require 'stringio'

class DelphianConsole
  def run
    while (input = prompt_command) != DelphianCommands::Exit
      handle(input)
    end

    puts "Exiting ..."
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
    when DelphianCommands::List
      list_entries
    when DelphianCommands::Close
      close
    when DelphianCommands::Modify
      modify
    when DelphianCommands::Add
      add_entry
    when DelphianCommands::Remove
      remove_entry
    when DelphianCommands::Save
      save_entries
    when DelphianCommands::New
      create_blank_entries
    when DelphianCommands::Search
      search
    when DelphianCommands::Stats
      display_stats
    end
  end

  def print_help
    puts <<END_OF_BODY


#{DelphianCommands::Exit}        exit interactive session
#{DelphianCommands::Load}        load encrypted password file
#{DelphianCommands::List}        list entries
#{DelphianCommands::Modify}      modify an entry
#{DelphianCommands::Add}         add a new entry
#{DelphianCommands::Remove}      Remove entry 
#{DelphianCommands::New}         create blank set of entries
#{DelphianCommands::Search}      search through password entries
#{DelphianCommands::Stats}       display stats on the passwords
#{DelphianCommands::Save}        save changes to an encrypted file
#{DelphianCommands::Close}       close loaded password entries


END_OF_BODY
  end

  def create_blank_entries
    @password_entries = []
    puts "Created empty set of password entries"
  end

  def load_encrypted_file
    unless @password_entries.nil?
      puts "Closing currently loaded password entries"
      close
    end

    puts "Enter encrypted file to load: "
    filename = File.expand_path(STDIN.gets.chomp)

    unless File.file?(filename)
      puts "#{filename} doesn't exist"
      return
    end

    @password_file = File.new(filename, 'rb')
    raw_decryption = StringIO.new
    blowfish = get_passphrase

    blowfish.decrypt_stream(@password_file, raw_decryption)

    @password_entries = []
    raw_decryption.string.split("\n").each {|line|
      items = line.split(',')
      password_entry = PasswordEntry.new(items[0], items[1], items[2], items[3])
      @password_entries << password_entry
    }

    puts "Password entries successfully loaded."
  end

  def list_entries
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "\nEntries:\n"
    @password_entries.each {|entry|
      puts entry.to_s
    }
  end

  def close
    @password_file.close unless @password_file.nil?
    @password_file = nil
    @password_entries = nil
    puts "Entries closed"
  end

  def display_stats
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    total_count = @password_entries.count
    password_count = {}
    @password_entries.each {|entry|
      if password_count[entry.password].nil?
        password_count[entry.password] = 1
      else
        password_count[entry.password] += 1
      end
    }
    password_count = password_count.sort_by {|key,value| value}.reverse

    puts "Statistics:"
    puts "Total entries: #{total_count}"
    password_count.each { |entry|
      puts "password: #{entry[0]}  count:#{entry[1]}  %:#{entry[1]/total_count.to_f}"
    }
  end

  def search
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "Enter search term:"
    search_term = STDIN.gets.strip
    i = 0
    @password_entries.each {|entry|
      if entry.contains(search_term)
        puts "(#{i.to_s}) #{entry.to_s}"
        i += 1
      end
    }
  end

  def add_entry
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "Enter name:"
    name = STDIN.gets.strip

    puts "Enter url:"
    url = STDIN.gets.strip

    puts "Enter username:"
    username = STDIN.gets.strip

    puts "Enter password:"
    password = STDIN.gets.strip

    password_entry = PasswordEntry.new(name, url, username, password)
    @password_entries << password_entry

    puts "New entry added"
  end

  def remove_entry
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "Enter search term:"
    search_term = STDIN.gets.strip
    i = 0
    matched_entries = []
    @password_entries.each {|entry|
      if entry.contains(search_term)
        matched_entries << entry
        puts "(#{i.to_s}) #{entry.to_s}"
        i += 1
      end
    }

    if matched_entries.count <= 0
      puts "No matching entries"
      return
    end

    puts "(#{i}) return to main menu"

    puts "Enter number of entry to delete:"
    entry = STDIN.gets.strip.to_i

    if entry < 0 || entry >= matched_entries.count
      puts "Returning to main menu"
      return
    end

    @password_entries.delete(matched_entries[entry])
    puts "Entry successfully removed"
  end

  def modify
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "Enter search term:"
    search_term = STDIN.gets.strip
    i = 0
    matched_entries = []
    @password_entries.each {|entry|
      if entry.contains(search_term)
        matched_entries << entry
        puts "(#{i.to_s}) #{entry.to_s}"
        i += 1
      end
    }

    if matched_entries.count <= 0
      puts "No matching entries"
      return
    end

    puts "(#{i}) return to main menu"

    puts "Enter number:"
    entry = STDIN.gets.strip.to_i

    if entry < 0 || entry >= matched_entries.count
      puts "Returning to main menu"
      return
    end

    begin
      puts "Which attribute to you want to modify?"
      puts "(1) name  #{matched_entries[entry].name}"
      puts "(2) url  #{matched_entries[entry].url}"
      puts "(3) username  #{matched_entries[entry].username}"
      puts "(4) password  #{matched_entries[entry].password}"
      puts "(5) done"

      attribute_index = STDIN.gets.strip.to_i
      if attribute_index <= 0 || attribute_index > 5
        next
      end

      if attribute_index == 5
        puts "Returning to main menu"
        return
      end

      puts "Enter new value:"
      new_value = STDIN.gets.strip
      case attribute_index
      when 1
        matched_entries[entry].name = new_value
      when 2
        matched_entries[entry].url = new_value
      when 3
        matched_entries[entry].username = new_value
      when 4
        matched_entries[entry].password = new_value
      end
    end while true

    puts "Entry modified successfully"
  end

  def save_entries
    if @password_entries.nil?
      puts "No password file loaded"
      return
    end

    puts "Enter file to save to: "
    filename = File.expand_path(STDIN.gets.chomp)

    if File.file?(filename)
      while true
        puts "#{filename} exists. Overwrite? (y/n)"
        confirm = STDIN.gets.strip
        if confirm =~ /\An/i
          return
        elsif confirm =~/\Ay/i
          break
        else
          puts "invalid input"
        end
      end

      File.delete(filename)
    end

    # serialize in-memory password entries to string
    raw_unencryption = StringIO.new("", "w+")
    @password_entries.each {|entry|
      raw_unencryption.write entry.to_serialized_format
      raw_unencryption.write "\n"
    }
    raw_unencryption.rewind

    # get file handle and passphrase
    save_file = File.new(filename, 'wb+')
    blowfish = get_passphrase

    blowfish.encrypt_stream(raw_unencryption, save_file)

    puts "Password entries successfully saved."
  end
end