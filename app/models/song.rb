class Song
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title,               :type => String, :default => ""
  field :artist,              :type => String, :default => ""
  field :notes,              :type => Array, :default => []
  field :featured,            :type => Boolean, :default => false
  field :original_song_id,    :type => String
  field :facebook_shares,     :type => Hash, :default => {}
  field :play_count,          :type => Integer, :default => 0
  field :listen_count,        :type => Integer, :default => 0
  field :image_url,           :type => String

  belongs_to :user

  attr_accessible :title, :artist, :notes, :user, :original_song_id

  scope :featured, where(:featured => true)

  #validates_presence_of :user
  #validates_presence_of :notes

  def original_song
    return Song.find(self.original_song_id) if self.original_song_id.present?
    nil
  end

  def increment_play_count!
    self.play_count += 1
    self.save
  end

  def increment_listen_count!
    self.listen_count += 1
    self.save
  end

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :artist => self.artist,
      :notes => self.notes,
      :listen_count => self.listen_count,
      :play_count => self.play_count,
      :user_id => self.user.present? ? self.user.id : nil,
      :user_name => self.user.present? ? self.user.name : nil,
      :user_pic => self.user.present? ? self.user.remote_pic_url : nil
    }
  end

  def share_on_facebook(user, link_to_song, message = nil)
    message ||= Song.default_share_message(self.title)
    if post = user.facebook_api.put_wall_post(message, {:link => link_to_song})
      self.facebook_shares[user.id] = post['id']
      true
    else
      false
    end
  end

  def like_on_facebook(user)
    #user.facebook_graph_api.put_like(facebook_post_id)
  end
end
