class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :filepicker_url
end
