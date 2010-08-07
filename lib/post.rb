class Post < Item

  key :title
  key :stub, :unique => true
  key :tags, Array

end
