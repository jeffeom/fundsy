require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  def valid_attributes(new_attributes = {})
    {first_name: Faker::Name.first_name,
     last_name:  Faker::Name.last_name,
     email:      Faker::Internet.email,
     password:   Faker::Internet.password
   }.merge(new_attributes)
  end

  describe "#new" do
    it "creates an instance variable with new user object" do
      get :new
      # this tests that there is an instance variable named `@user`  that is a
      # new object of the User class
      expect(assigns(:user)).to be_a_new(User)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates the user in the database" do
        # expect do
        #   post(:create, {user: valid_attributes})
        # end.to change { User.count }.by(1)
        count_before = User.count
        post(:create, {user: valid_attributes})
        count_after  = User.count
        expect(count_after - count_before).to eq(1)
      end

      it "redirects to the home page" do
        post(:create, {user: valid_attributes})
        expect(response).to redirect_to(root_path)
      end

      it "sets a flash message" do
        post(:create, {user: valid_attributes})
        expect(flash[:notice]).to be
      end
    end
    context "with invalid params" do
      it "doesn't create a user in the database" do
        count_before = User.count
        post :create, user: valid_attributes({email: nil})
        count_after = User.count
        expect(count_after).to eq(count_before)
      end

      it "renders the new template" do
        post :create, user: valid_attributes({email: nil})
        expect(response).to render_template(:new)
      end
    end
  end

end
