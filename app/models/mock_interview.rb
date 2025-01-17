# == Schema Information
#
# Table name: mock_interviews
#
#  id             :bigint           not null, primary key
#  start_date     :date             not null
#  start_time     :time             not null
#  status         :string           default("pending"), not null
#  time_zone      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accepted_by_id :bigint
#  created_by_id  :bigint           not null
#
# Indexes
#
#  index_mock_interviews_on_accepted_by_id  (accepted_by_id)
#  index_mock_interviews_on_created_by_id   (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (accepted_by_id => users.id)
#  fk_rails_...  (created_by_id => users.id)
#
class MockInterview < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true

  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :status, inclusion: { in: %w[pending accepted completed] }
  validate :start_time_in_future

  private
  
  def start_time_in_future
    return if start_date.blank? || start_time.blank?


    Rails.logger.debug("Start Date: #{start_date}")
    Rails.logger.debug("Start Time: #{start_time}")
    
    # Combine start_date and start_time into a full datetime object in the specified time zone
    full_start_datetime = Time.use_zone("Eastern Time (US & Canada)") do
      Time.zone.parse("#{start_date} #{start_time}")
    end

    Rails.logger.debug("Converted Start Time: #{full_start_datetime}")
  
    # Get the current time in the same time zone
    est_now = Time.zone.now.in_time_zone("Eastern Time (US & Canada)")
  
    # Validate that the start time is at least 30 minutes in the future
    if full_start_datetime < est_now + 30.minutes
      errors.add(:start_time, "must be at least 30 minutes from now")
    end
  end
  
end
