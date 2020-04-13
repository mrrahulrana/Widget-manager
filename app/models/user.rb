class User
    include ActiveModel::Model
    attr_accessor :id,:firstname,:lastname, :email, :password, :email, :imageurl
    #validates :name, presence: true
    validates :email, presence: true, length: {in:5..255}
end
