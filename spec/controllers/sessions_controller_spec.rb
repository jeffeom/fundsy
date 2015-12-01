require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  describe "#new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    context "with correct credentials" do
      it "sets the sessions user_id to the user with the email" do
        # GIVEN
        user # this will call the user defined by let(:user) which creates a user

        # WHEN
        post :create, {email: user.email, password: user.password}

        # THEN
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to home page" do
        post :create, {email: user.email, password: user.password}
        expect(response).to redirect_to(root_path)
      end
    end
    context "with incorrect credentials" do
      before { post :create, email: user.email, password: nil }

      it "doesn't set the sessions id" do
        expect(session[:user_id]).to be_nil
      end

      it "renders the new template" do
        expect(response).to render_template(:new)
      end

      it "shows an alert message" do
        expect(flash[:alert]).to be
      end
    end
  end

  describe "#destroy" do
    it "sets the session id to nil for the :user_id" do
      request.session[:user_id] = user.id
      delete :destroy
      expect(session[:user_id]).not_to be
    end

    it "redirects to home page" do
      request.session[:user_id] = user.id
      delete :destroy
      expect(response).to redirect_to(root_path)
    end
  end
end
