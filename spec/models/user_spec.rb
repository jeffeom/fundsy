require 'rails_helper'

RSpec.describe User, type: :model do

  def valid_attributes(new_attributes = {})
    {
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      email:      Faker::Internet.email,
      password:   Faker::Internet.password
    }.merge(new_attributes)
  end

  # describe can be used to define a group of test examples together
  describe "validations" do

    # we use `it` method to define a test example
    it "requires an email" do
      # Given: a new user record with no email
      # when:  we try to validate it
      # then:  it's invalid

      # # GIVEN
      # user = User.new
      # # WHEN
      # outcome = user.valid?
      # # THEN
      # expect(outcome).to eq(false)

      user = User.new(valid_attributes(email: nil))
      # we use the `expect` method by RSpec to test the outcome of the test
      expect(user).to be_invalid
    end

    it "requires a first name" do
      u = User.new(valid_attributes(first_name: nil))
      # u.email = "someithing@valid.com"
      expect(u).to be_invalid
    end

    it "requires a last name" do
      u = User.new
      u.valid?
      # have_key is an RSpec matcher that uses has_key? method in the Ruby
      # Hash class
      expect(u.errors.messages).to have_key(:last_name)
    end

    it "requies an email with a proper format" do
      u = User.new(valid_attributes(email: "test"))
      expect(u).to be_invalid
    end

  end

  describe "generating password digest" do

    it "generates a password_digest upon saving" do
      # GIVEN
      u = User.new valid_attributes
      # WHEN
      u.save
      # THEN
      expect(u.password_digest).to be
    end

  end

  describe ".full_name" do
    it "returns the first name and last name concatenated" do
      attributes = valid_attributes
      u = User.new(attributes)
      expect(u.full_name).to eq("#{attributes[:first_name]} #{attributes[:last_name]}")
    end
  end

end
