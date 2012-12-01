class LeaderboardController < ApplicationController
  def index
    @songs = Song.all.includes(:user)
  end
end