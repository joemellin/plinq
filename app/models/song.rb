class Song
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title,               :type => String, :default => ""
  field :artist              :type => String
  field :notes,              :type => Array, :default => []
  field :featured, :type => Boolean, :default => false

  belongs_to :user

  attr_accessible :title, :artist, :notes, :user

  scope :featured, where(:featured => true)

  #validates_presence_of :user
  #validates_presence_of :notes

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :artist => self.artist,
      :notes => self.notes
    }
  end
end
