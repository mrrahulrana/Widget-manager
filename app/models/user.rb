class User
    include ActiveModel::Model
    attr_accessor :id,:firstname,:lastname, :email, :password, :dateofbirth, :imageurl
    validates :firstname, presence: true
    validates :lastname, presence: true
    validates :password, presence: true
    validates :email, presence: true, length: {in:5..255}
end
