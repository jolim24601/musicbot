require 'uri'
require 'securerandom'
require 'cgi'
require 'securerandom'

url = "https://www.youtube.com/watch/fdsafsfd"
uri = URI.parse(url)
params = CGI.parse(uri.query) if uri.query
host = uri.host.downcase

filename = SecureRandom.alphanumeric(10)
if params and params["v"]&.first 
    filename = params["v"].first
elsif uri.path
    filename = uri.path.split("/")[-1]
end

p filename

