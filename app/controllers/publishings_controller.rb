class PublishingsController < ApplicationController
  def create
    campaign = Campaign.find params[:campaign_id]
    if campaign.publish
      campaign.save
      redirect_to campaign, notice: "Campaign Published!"
    else
      redirect_to campaign, alert: "Error! Can't publish campaign."
    end
  end
end
