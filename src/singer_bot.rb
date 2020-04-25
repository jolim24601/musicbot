require 'discordrb'
require 'youtube_audio_downloader'
require 'json'

file = File.read('info.json')
info = JSON.parse(file)
bot = Discordrb::Commands::CommandBot.new token: info["token"], client_id: 703699250042896566, prefix: 'Play '

bot.command(:song) do |event, *args|
  p args

  url = args.first
  next "You need to provide a song link" unless url

  YoutubeAudioDownloader.download_audio(args.first, ".", "music.webm")
  p "Done downloading audio"

  channel = event.author.voice_channel
  next "You're not in any voice channel!" unless channel

  p "Connecting to channel #{channel}"
  voice_bot = bot.voice_connect(channel)

  p "Playing audio"
  voice_bot.play_file('music.mp3')
end

bot.run