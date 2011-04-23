# require "rexml/document"

# require "gdata"

# desc "Retrieve one page of Contacts and write to standard output"
# task(:retrieve_one_page) do
#   email = "?????????"
#   pw = "????"

#   client = GData::Client::Contacts.new
#   client.clientlogin(email, pw)

#   url = "http://www.google.com/m8/feeds/contacts/#{email}/thin"
#   data = client.get(url).to_xml
#   fmt = REXML::Formatters::Pretty.new
#   raw_data = ""
#   fmt.write(data, raw_data)

#   puts raw_data

#   #Nokogiri::XML.Reader(raw_data).each do |node|
#   #  puts node.value
#   #end
# end
