class Song
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,               :type => String, :default => ""
  field :notes,              :type => Array, :default => []
  field :featured, :type => Boolean, :default => false

  belongs_to :user

  attr_accessible :name, :notes, :user

  scope :featured, where(:featured => true)

  #validates_presence_of :user
  #validates_presence_of :notes

  def as_json(options = {})
    {
      :id => self.id,
      :name => self.name,
      :notes => self.notes
    }
  end
end
