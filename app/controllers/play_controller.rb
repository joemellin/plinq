class PlayController < ApplicationController
  def index
    load_songs
    @song = @songs.first if @songs.present?
    render 'songs/song'
  end
end