class Shepherd
  include DataMapper::Resource

  property :id, Serial
  property :project, String
  property :name, String
end
