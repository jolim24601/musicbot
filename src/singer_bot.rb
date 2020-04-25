require 'discordrb'
require 'youtube_audio_downloader'


bot.message(with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.command(:song) do |event, *args|
    p args
  # `event.voice` is a helper method that gets the correct voice bot on the server the bot is currently in. Since a
  # bot may be connected to more than one voice channel (never more than one on the same server, though), this is
  # necessary to allow the differentiation of servers.
  #
  # It returns a `VoiceBot` object that methods such as `play_file` can be called on.

#   YoutubeAudioDownloader.download_audio(args.first, ".", "music.webm")

  bot.voice_connect(event.author.voice_channel)

  voice_bot = event.voice
  voice_bot.play_file('music.mp3')
end


bot.run