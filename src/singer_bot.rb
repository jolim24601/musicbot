require 'discordrb'
require_relative 'streamer'
require 'json'
require 'securerandom'

file = File.read('info.json')
info = JSON.parse(file)
bot = Discordrb::Commands::CommandBot.new token: info["token"], client_id: 703699250042896566, prefix: 'Play '

def delete_oldest_file()
  Dir.glob("data/*.webm").each { |file| File.delete(file) if File.file? file }

  paths = []
  Dir.glob("data/*.mp3").each { |file| paths << file if File.file? file }

  if paths.length > 12
    paths = paths.sort_by {|f| File.mtime(f)}
    p "Deleting #{paths.first}"
    File.delete(paths.first)
  end
end

bot.command(:song) do |event, *args|
  p args
  next "You're already playing something. Say 'Play stop' if you want to stop the current track." if event&.voice&.playing?  

  url = args.first
  next "You need to provide a song link" unless url
  
  channel = event.author.voice_channel
  next "You're not in any voice channel!" unless channel

  uri = URI.parse(url)
  host = uri.host.downcase
  unless host.include? "youtu.be" or host.include? "youtube.com"
    next "I only support YouTube atm. Sorry."
  end

  params = CGI.parse(uri.query) if uri.query
  filename = SecureRandom.alphanumeric(10)
  if params and params["v"]&.first 
    filename = params["v"].first
  elsif uri.path
    filename = uri.path.split("/")[-1]
  end

  location = "data/#{filename}.mp3"
  p location

  unless File.file? location
    delete_oldest_file()

    YoutubeAudioDownloader.download_audio(args.first, "data", "#{filename}.webm")
    p "Done downloading audio"

    numTries = 100
    until File.file? location do
      numTries -= 1
      break if numTries < 1
      p "Sleeping. #{numTries} tries left."
      sleep 3
    end

    next "Timed out trying to get #{url} after 5 mins. Sorry." unless File.file? location
  end

  p "Connecting to channel #{channel}"
  voice_bot = bot.voice_connect(channel)

  p "Playing audio"
  voice_bot.play_file(location)
end

bot.command(:stop) do |event|
  event&.voice&.stop_playing()
end

bot.run