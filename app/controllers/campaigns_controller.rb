class CampaignsController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_campaign, only: [:edit, :update, :destroy, :show]

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new campaign_params
    @campaign.user = current_user
    if @campaign.save
      redirect_to campaign_path(@campaign)
    else
      render :new
    end
  end

  def show
  end

  def edit
    if @campaign.user != current_user
      redirect_to root_path, alert: 'Access denied!'
    end
  end

  def update
    if @campaign.user != current_user
      redirect_to root_path
    elsif @campaign.update campaign_params
      redirect_to campaign_path(@campaign)
    else
      render :edit
    end
  end

  def index
    @campaigns = Campaign.order(:created_at)
  end

  def destroy
    if current_user == @campaign.user
      @campaign.destroy
      redirect_to campaigns_path
    else
      redirect_to root_path
    end
  end

  private

  def find_campaign
    @campaign = Campaign.find params[:id]
  end

  def campaign_params
    campaign_params = params.require(:campaign).permit(:title, :goal,                                                        :description, :end_date)
  end
end
