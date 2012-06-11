require 'crypt/blowfish'

def string_is_nil_or_empty(str)
    return str.nil? || str.chomp.empty?
end

if (ARGV.length < 3) || (!['encrypt', 'decrypt'].include? ARGV[0])
    puts 'Usage: <action> <arguments>'
    puts
    puts 'To encrypt a file, specify  unencrypted file and output:'
    puts 'encrypt <unencrypted_filename> <encrypted_filename>'
    puts
    puts 'To decrypt a file, specify encrypted file and output'
    puts 'decrypt <encrypted_filename> <decrypted_filename>'
    exit 1
end

action = ARGV[0]
filename1 = ARGV[1]
filename2 = ARGV[2]

if string_is_nil_or_empty(filename1) || !File.exists?(filename1)
	puts "first parameter is an invalid filename: #{filename1}"
	puts "check if it exists" 
	return
end

dirname = File.dirname(filename2)
if !Dir.exists?(dirname)
    FileUtils.mkdir_p(dirname)
end

puts "What is your passphrase?"
key = STDIN.gets.chomp
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


