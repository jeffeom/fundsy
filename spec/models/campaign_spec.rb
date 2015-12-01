require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe "validations" do
    it "requires a title" do
      campaign = Campaign.new
      campaign.valid?
      expect(campaign.errors.messages).to have_key(:title)
    end

    it "requires a goal" do
      campaign = Campaign.new
      campaign.valid?
      expect(campaign.errors.messages).to have_key(:goal)
    end

    it "requires a gaol that is more than $10" do
      campaign = Campaign.new(goal: 5)
      campaign.valid?
      expect(campaign.errors.messages).to have_key(:goal)
    end
  end
end
