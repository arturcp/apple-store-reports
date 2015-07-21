require 'open-uri'

class Icon
  URL = "https://itunes.apple.com/br/app/%{title}/id%{apple_identifier}"
  attr_accessor :body

  def self.fetch(title, apple_identifier)
      href = ''
      url = URL % { title: title, apple_identifier: apple_identifier }
      message = "Fetching icon from #{url}"

      dots = '.' * (130 - message.length).abs
      print message

      open(url) do |f|
        href = image_url(f.readlines.join(' '))
      end

      if href.empty?
        print "#{dots} #{"not found".red}\n"
      else
        print "#{dots} #{"done".green}\n"
      end

      href
    rescue
      print "#{dots} #{"not found".red}\n"
      ""
  end

  private

  def self.image_url(body)
    regex = /<meta itemprop=\"image\" content=\"([\w\:\/\.\-\_]+)\"><\/meta>/i
    body.scan(regex).flatten.first
  end
end