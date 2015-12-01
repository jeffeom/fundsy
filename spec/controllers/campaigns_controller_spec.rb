require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  # let will define a variable names whatever you give to the let which is `user`
  # in this case. The variable will be available in any test exmple within the
  # same `describe` or `context`. This `let` is defined in the top level describe
  # which makes it availalbe for all examples.
  # `let` will only invoke the block you give it when you call the variable.
  # if you use `let!` then it will automatically invoke the block every time
  # you run an example even if you don't use the variable.
  let(:user) { FactoryGirl.create(:user) }
  # def user
  #   @user ||= FactoryGirl.create(:user)
  # end

  let(:campaign)   { FactoryGirl.create(:campaign, user: user) }
  # we're able to just put 'create(:campaign)' instead of
  # FacotryGirl.create(:campaign) because we added this line to our 'rails_helper'
  # file: config.include FactoryGril::Syntax::Methods
  # let(:campaign_1) { FactoryGirl.create(:campaign) }
  let(:campaign_1) { create(:campaign) }

  describe '#new' do
    context 'with user not signed in' do
      it 'redirects to user sign in page' do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
    context 'with user signed in' do
      before do
        # GIVEN
        u = FactoryGirl.create(:user)
        request.session[:user_id] = u.id

        # WHEN
        get :new
      end

      it 'renders the new template' do
        # THEN
        expect(response).to render_template(:new)
      end

      it 'create a new campaign object assigned to `campaign` instance variable' do
        # THEN
        expect(assigns(:campaign)).to be_a_new(Campaign)
      end
    end
  end

  describe '#create' do
    context 'with no user signed in' do
      it 'redirects to the sign in page' do
        post :create, campaign: {} # params don't matter here becuase the
        # controller should redirect before making
        # use of the campaign params
        expect(response).to redirect_to new_session_path
      end
    end

    context 'With user signed in' do
      def valid_params
        FactoryGirl.attributes_for(:campaign)
      end

      before do
        request.session[:user_id] = user.id
      end

      context 'with valid parameters' do
        it 'creates a campaign record in the database' do
          before_count = Campaign.count
          post :create, campaign: valid_params
          after_count = Campaign.count
          expect(after_count - before_count).to eq(1)
        end

        it 'associates the campaign with the signed in user' do
          post :create, campaign: valid_params
          expect(Campaign.last.user).to eq(user)
        end

        it 'redirects to campaign show page' do
          post :create, campaign: valid_params
          expect(response).to redirect_to(campaign_path(Campaign.last))
        end
      end
      context 'with invalid parameters' do
        def request_with_invalid_title
          post :create, campaign: valid_params.merge(title: nil)
        end

        it "doesn't create a campaign record in the database" do
          # expect { request_with_invalid_title }.not_to change { Campaign.count }
          before_count = Campaign.count
          request_with_invalid_title
          after_count = Campaign.count
          expect(before_count).to eq(after_count)
        end

        it 'renders the new template' do
          request_with_invalid_title
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe '#show' do
    it 'renders the show template' do
      get :show, id: campaign.id
      expect(response).to render_template(:show)
    end

    it 'sets a campaign instance variable with the passed id' do
      get :show, id: campaign.id
      # there must be an instance variable named @campaign
      expect(assigns(:campaign)).to eq(campaign)
    end
  end

  describe '#edit' do
    context 'with user not signed in' do
      it 'redirects to sign in page' do
        get :edit, id: campaign.id
        expect(response).to redirect_to new_session_path
      end
    end
    context 'with user signed in' do
      before { request.session[:user_id] = user.id }

      # we defined our `campaign` above so that the creator of the campaign is
      # `user` so `user` is the owner of the campaign so the user can edit it
      context 'with user allowed to edit campaign' do
        it 'renders the edit template' do
          get :edit, id: campaign.id
          expect(response).to render_template(:edit)
        end

        it 'assigns an instance variable with the same id as the one in the URL' do
          get :edit, id: campaign.id
          expect(assigns(:campaign)).to eq(campaign)
        end
      end
      context 'with user not allowed to edit campaign' do


        it 'redirects to the home page' do
          get :edit, id: campaign_1.id
          expect(response).to redirect_to root_path
        end

        it 'sets a flash alert message' do
          get :edit, id: campaign_1.id
          expect(flash[:alert]).to be
        end
      end
    end
  end

  describe '#update' do
    context 'with no signed in user' do
      it 'redirects the user to the sign in page' do
        patch :update, id: campaign.id, campaign: {}
        expect(response).to redirect_to new_session_path
      end
    end

    context 'with signed in user' do
      before { request.session[:user_id] = user.id }

      context 'user is allowed to update the campaign' do
        context 'with valid paramters' do
          it 'redirects to show page' do
            patch :update, id: campaign.id, campaign: { title: 'new valid title' }
            expect(response).to redirect_to campaign_path(campaign)
          end
          it 'changes the record in the database with new params' do
            patch :update, id: campaign.id, campaign: { title: 'new valid title' }
            # campaign.reload will force the object to re-execute the query
            # (find query) to re-fetch the data from the database using the#
            # same id. As if you did:
            # campaign = Campaign.find(campaign.id)
            expect(campaign.reload.title).to eq('new valid title')
          end
        end
        context 'with invalid paramters' do
          it 'render the edit page' do
            patch :update, id: campaign.id, campaign: { title: '' }
            expect(response).to render_template(:edit)
          end
          it "doesn't change the record in the database" do
            patch :update, id: campaign.id, campaign: { title: '',
                                                        description: 'valid desc' }
            expect(campaign.reload.description).not_to eq('valid desc')
          end
        end
      end
      context 'user is not allowed to update the campaign' do


        it 'redirects to home page' do
          patch :update, id: campaign_1.id, campaign: { title: 'some valid title' }
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe '#index' do


    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns an instance variable campaigns with all the campaigns' do
      # GIVEN: we have campaigns created in the database
      campaign
      campaign_1
      # WHEN: Making the GET request to the INDEX action
      get :index
      # THEN: I have an instance variable @campaigns that contain the two campaigns
      expect(assigns[:campaigns]).to eq([campaign, campaign_1])
    end
  end

  describe '#destroy' do
    context 'with user not signed in' do
      it 'redirects the user to the sign in page' do
        delete :destroy, id: campaign.id
        expect(response).to redirect_to new_session_path
      end
    end
    context 'with user signed in' do
      before { request.session[:user_id] = user.id }

      context 'user is allowed to delete the campaign' do
        it 'removes the campaign from the database' do
          campaign # this makes the campaign created in the database
          count_before = Campaign.count
          delete(:destroy, id: campaign.id)
          count_after = Campaign.count
          expect(count_before - count_after).to eq(1)
        end
        it 'redirects to the campaigns index page' do
          delete(:destroy, id: campaign.id)
          expect(response).to redirect_to(campaigns_path)
        end
      end
      context 'user is not allowed to delete the campaign' do

        it 'redirects the user to the home page' do
          delete :destroy, id: campaign_1.id
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
