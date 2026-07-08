# isbn_generator.rb
class ISBNGenerator
  def self.validate_isbn10(isbn)
    clean = isbn.gsub(/[-\s]/, '')
    return false unless clean.length == 10
    return false unless clean =~ /^\d{9}[0-9Xx]$/
    total = 0
    clean.each_char.with_index do |ch, i|
      val = (ch =~ /[Xx]/) ? 10 : ch.to_i
      total += val * (10 - i)
    end
    total % 11 == 0
  end

  def self.validate_isbn13(isbn)
    clean = isbn.gsub(/[-\s]/, '')
    return false unless clean.length == 13 && clean =~ /^\d{13}$/
    total = 0
    clean.each_char.with_index do |ch, i|
      digit = ch.to_i
      total += digit * (i.even? ? 1 : 3)
    end
    total % 10 == 0
  end

  def self.validate(isbn)
    clean = isbn.gsub(/[-\s]/, '')
    if clean.length == 10
      [validate_isbn10(isbn), 'ISBN-10']
    elsif clean.length == 13
      [validate_isbn13(isbn), 'ISBN-13']
    else
      [false, 'Unknown']
    end
  end

  def self.generate_isbn10(prefix = '')
    clean = prefix.gsub(/[-\s]/, '')
    if clean != ''
      raise "Prefix must be digits and up to 9 chars." unless clean =~ /^\d+$/ && clean.length <= 9
      clean = clean.ljust(9, '0')
    else
      clean = 9.times.map { rand(10).to_s }.join
    end
    total = 0
    clean.each_char.with_index do |ch, i|
      total += ch.to_i * (10 - i)
    end
    check = (11 - (total % 11)) % 11
    check_char = check == 10 ? 'X' : check.to_s
    clean + check_char
  end

  def self.generate_isbn13(prefix = '')
    clean = prefix.gsub(/[-\s]/, '')
    if clean != ''
      raise "Prefix must be digits and up to 12 chars." unless clean =~ /^\d+$/ && clean.length <= 12
      clean = clean.ljust(12, '0')
    else
      clean = 12.times.map { rand(10).to_s }.join
    end
    total = 0
    clean.each_char.with_index do |ch, i|
      digit = ch.to_i
      total += digit * (i.even? ? 1 : 3)
    end
    check = (10 - (total % 10)) % 10
    clean + check.to_s
  end

  def self.batch_generate(type, prefixes)
    results = []
    prefixes.each do |p|
      p = p.strip
      next if p.empty?
      begin
        isbn = type == '10' ? generate_isbn10(p) : generate_isbn13(p)
        results << isbn
      rescue => e
        results << "Error for '#{p}': #{e.message}"
      end
    end
    results
  end
end

def main
  puts "=== ISBN Generator ==="
  loop do
    puts "\n1. Generate ISBN-10"
    puts "2. Generate ISBN-13"
    puts "3. Validate an ISBN"
    puts "4. Batch generate from file"
    puts "5. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      print "Enter prefix (group-publisher-title, leave blank for random): "
      prefix = gets.chomp
      begin
        isbn = ISBNGenerator.generate_isbn10(prefix)
        puts "Generated ISBN-10: #{isbn}"
        puts "Check digit: #{isbn[-1]}"
      rescue => e
        puts "Error: #{e.message}"
      end
    when '2'
      print "Enter prefix (group-publisher-title, leave blank for random): "
      prefix = gets.chomp
      begin
        isbn = ISBNGenerator.generate_isbn13(prefix)
        puts "Generated ISBN-13: #{isbn}"
        puts "Check digit: #{isbn[-1]}"
      rescue => e
        puts "Error: #{e.message}"
      end
    when '3'
      print "Enter ISBN (with or without hyphens): "
      inp = gets.chomp
      valid, typ = ISBNGenerator.validate(inp)
      puts "Type: #{typ}"
      puts "Valid: #{valid}"
    when '4'
      print "Enter path to file with prefixes (one per line): "
      fname = gets.chomp
      begin
        prefixes = File.readlines(fname).map(&:chomp)
        print "Type (10 or 13): "
        typ = gets.chomp.strip
        results = ISBNGenerator.batch_generate(typ, prefixes)
        puts "\nBatch results:"
        results.each { |r| puts r }
      rescue => e
        puts "Error: #{e.message}"
      end
    when '5'
      puts "Goodbye!"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
