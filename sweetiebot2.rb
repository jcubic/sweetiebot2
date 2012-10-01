version="beta1.17"
puts "Cutie Mark Acquisition Program version "+version+" starting..."
require 'rubygems'
require "cinch"
require "open-uri"
require "nokogiri"
require "cgi"


bot = Cinch::Bot.new do
  configure do |c|
    c.server = "ircserver"
    c.nick = "omgwtf"
    c.channels = ["#forshitsandgiggles"]
  end

  on :message, ",info" do |m|
    m.reply "Cutie Mark Acquisition Program version "+version
  end

  helpers do
    def google(query)
      url = "http://www.google.com/search?q=#{CGI.escape(query)}"
      res = Nokogiri::HTML(open(url)).at("h3.r")
      title = res.text
      link = res.at('a')[:href]
      desc = res.at("./following::div").children.first.text
    rescue
      "No results found"
    else
      CGI.unescape_html "#{title} - #{desc} (#{link})"
    end
  end

  on :message, /^,g (.+)/ do |m, query|
	m.reply google(query)
  end

  on :message, /^,jargon *(.+) */ do |m, query|
    begin
      db = SQLite3::Database.open "jargon.db"
      stm = db.prepare "SELECT def FROM terms WHERE term like '#{query}'"

      rs = stm.execute
      rs.each do |row|
        m.reply row[0]
      end
    rescue SQLite3::Exception => e
      puts "Exception occured"
      puts e
    ensure
      db.close if db
    end
  end

end
bot.start
