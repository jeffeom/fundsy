module CampaignsHelper
  def label_class(state)
    case state
    when "draft"
      "label-default"
    when "published"
      "label-primary"
    when "funded"
      "label-success"
    when "unfunded"
      "label-danger"
    when "closed"
      "label-warning"
    end
  end
end
