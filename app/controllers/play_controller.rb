class PlayController < ApplicationController
  def index
    @songs = Song.featured.asc(:created_at).limit(20)
    @song = @songs.last if @songs.present?
  end
end