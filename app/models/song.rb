class Song
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title,               :type => String, :default => ""
  field :artist,              :type => String, :default => ""
  field :notes,              :type => Array, :default => []
  field :featured,            :type => Boolean, :default => false
  field :original_song_id,    :type => String
  field :facebook_shares,     :type => Hash, :default => {}

  belongs_to :user

  attr_accessible :title, :artist, :notes, :user, :original_song_id

  scope :featured, where(:featured => true)

  #validates_presence_of :user
  #validates_presence_of :notes

  def self.default_share_message
    "Come listen to this great song I played on Plinq!"
  end

  def original_song
    return Song.find(self.original_song_id) if self.original_song_id.present?
    nil
  end

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :artist => self.artist,
      :notes => self.notes,
      :user_id => self.user.id,
      :user_name => self.user.name
    }
  end

  def share_on_facebook(user, link_to_song, message = nil)
    message ||= Song.default_share_message
    if post = user.facebook_graph_api.put_wall_post(message, {:link => link_to_song})
      self.shares[user.id] = post.id
      true
    else
      false
    end
  end

  def like_on_facebook(user)
    #user.facebook_graph_api.put_like(facebook_post_id)
  end
end
