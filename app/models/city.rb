class City < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records

  has_many :locations
  validates_presence_of :description
  validates_numericality_of :longitude, :allow_nil => true;
  validates_numericality_of :latitude, :allow_nil => true;
  # note we can't simply check for uniqueness of name since there can be cities w same name

  def locations_sorted
    locations.sort_by {|x| x.description}
  end
  
  def to_s
    self.name
  end
  
end
