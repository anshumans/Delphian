require 'crypt/blowfish'
require_relative 'delphian_console'

def string_is_nil_or_empty(str)
    return str.nil? || str.chomp.empty?
end

def print_help
  puts 'Usage: <action> <arguments>'
  puts
  puts 'To encrypt a file, specify  unencrypted file and output:'
  puts 'ruby delphian.rb encrypt <unencrypted_filename> <encrypted_filename>'
  puts
  puts 'To decrypt a file, specify encrypted file and output:'
  puts 'ruby delphian.rb decrypt <encrypted_filename> <decrypted_filename>'
  puts
  puts 'To run Delphian in an interactive console:'
  puts 'ruby delphian.rb console'
  exit 1
end

begin
	if !['encrypt', 'decrypt', 'console'].include?(ARGV[0])
		print_help
	end

	action = ARGV[0]

	if action == 'console'
		DelphianConsole.new.run
	else
		if (ARGV.length < 3)
			print_help
		end

		filename1 = ARGV[1]
		filename2 = ARGV[2]

		if string_is_nil_or_empty(filename1) || !File.exists?(filename1)
			puts "first parameter is an invalid filename: #{filename1}"
			puts "check if it exists" 
			exit 1
		end

		dirname = File.dirname(filename2)
		if !Dir.exists?(dirname)
		    FileUtils.mkdir_p(dirname)
		end

		puts "What is your passphrase?"
		system "stty -echo"
		key = STDIN.gets.chomp
		system "stty echo"
		blowfish = Crypt::Blowfish.new(key)

		if action == "encrypt"
			blowfish.encrypt_file(filename1, filename2)
		elsif action == "decrypt"
			blowfish.decrypt_file(filename1, filename2)
		else
			puts "Invalid action: must be either 'encrypt' or 'decrypt'"
		end

		puts "Action successful!"

		pid = Process.spawn("mvim", filename2)
		Process.detach(pid)
	end
end
