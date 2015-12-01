FactoryGirl.define do
  factory :campaign do
    # this will create a user object for the campaign and associate it with the
    # created object unless you explicitly pass a `:user` attribute when
    # creating the campaign
    association :user, factory: :user

    sequence(:title)        { Faker::Company.bs }
    sequence(:goal)         { 11 + rand(1000000) }
    description             Faker::Lorem.paragraph
    end_date                60.days.from_now
  end

end
