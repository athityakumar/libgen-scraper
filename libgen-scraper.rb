require 'mechanize'
mechanize = Mechanize.new
mechanize.history_added = Proc.new { sleep 3 }
mechanize.follow_meta_refresh = true 
mechanize.verify_mode = OpenSSL::SSL::VERIFY_NONE
mechanize.pluggable_parser.default = Mechanize::Download 

unless Dir.exist? "pdf"
    Dir.mkdir("pdf")
end 
Dir.chdir("pdf")

if ARGV[0] == "testing"
  input , filename = "beer mechanics" , "test"
  ARGV[0].clear
else
  puts "Search for a book : "
  input , filename = gets.chomp , ""
end

input , hash_list , select = input.gsub("  "," ").gsub(" ","+") , [] , 0
query = "http://libgen.io/search.php?&req=#{input}&phrase=1&view=simple&column=def&sort=def&sortmode=ASC&page=1"
page = mechanize.get(query)
count = page.search(".c tr").count
puts "\n FINDING TOP RESULTS (25 OPTIONS AT MAX) \n"
for i in (1..count-1)
  auth , book = page.search(".c tr")[i].search("td")[1].text , page.search(".c tr")[i].search("td")[2].children.last.text  
  puts "(#{i}) #{book} - #{auth} "
  hash = page.search(".c tr")[i].search("td")[2].children.last["href"].split("md5=")[1]
  hash_list.push([hash,auth,book])
end
while !(select >= 1 && select <= i)
  puts "Select a book (1 - #{i}) : "
  select = gets.chomp.to_i
  filename = hash_list[select-1][2] + " " + hash_list[select-1][1]
  filename = filename.gsub(" ","_")
  puts "Starting download of #{filename}.pdf"
  mechanize.get("http://libgen.io/get/#{hash_list[select-1][0]}/#{filename}.pdf").save
  puts "Finished download of #{filename}.pdf"
end
