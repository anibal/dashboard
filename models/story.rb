class Story
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :billed, Boolean
end
