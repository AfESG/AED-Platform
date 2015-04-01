class User < ActiveRecord::Base
  has_paper_trail

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :job_title, :department, :organization, :phone, :fax, :address_1, :address_2, :address_3, :city, :country, :admin, :email, :password, :password_confirmation, :remember_me
  validates_presence_of :name

  def active_for_authentication?
    super and !self.disabled?
  end

end
