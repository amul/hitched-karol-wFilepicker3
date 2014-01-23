class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :notes

  after_create :make_default_note

  def make_default_note
    notes.create!(title: "I'm getting married", body: 'January 2015')
  end
end
