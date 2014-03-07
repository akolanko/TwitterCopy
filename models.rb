class User < ActiveRecord::Base
	has_many :posts, dependent: :destroy
	has_one :profile, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower
	
	def following?(other_user)
		relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
		relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
		relationships.find_by(followed_id: other_user.id).destroy
	end
end

class Post < ActiveRecord::Base
	belongs_to :user
end

class Relationship < ActiveRecord::Base
	belongs_to :follower, class_name: "User"
	belongs_to :followed, class_name: "User"
end

class Profile < ActiveRecord::Base
	belongs_to :user
end