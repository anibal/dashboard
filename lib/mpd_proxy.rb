class MpdProxy
  @current_song = nil
  @time = 0
  
  class << self
    def setup(server, port, callbacks = false)
      mpd = MPD.new(server, port)
      mpd.register_callback method(:current_song=), MPD::CURRENT_SONG_CALLBACK
      mpd.register_callback method(:time=), MPD::TIME_CALLBACK
      mpd.connect callbacks
    rescue SocketError
    end
    
    def current_song; @current_song end
    def current_song=(song = nil) @current_song = (song ? "#{song.artist} - #{song.title}" : nil) end
    
    def time; @time end
    def time=(elapsed, total); @time = total - elapsed end
  end
end