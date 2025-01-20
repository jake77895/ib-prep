# == Schema Information
#
# Table name: mock_interviews
#
#  id                        :bigint           not null, primary key
#  acceptor_reliability_flag :string
#  check_date_time           :datetime
#  creator_reliability_flag  :string
#  start_date                :date             not null
#  start_time                :time             not null
#  status                    :string           default("pending"), not null
#  time_zone                 :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  accepted_by_id            :bigint
#  created_by_id             :bigint           not null
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
  validates :status, inclusion: { in: %w[pending accepted completed cancelled] }
  validate :start_time_in_future, if: :validate_start_time?

  # Add this method to explicitly allow attributes to be searchable
  def self.ransackable_attributes(auth_object = nil)
    %w[start_date check_date_time status] +
    %w[created_by_id accepted_by_id time_zone] +
    MockInterviewProfile.ransackable_attributes
  end

  # Allow associations to be included in searches
  def self.ransackable_associations(auth_object = nil)
    %w[created_by created_by.mock_interview_profile]
  end

  def cancel_by_creator
    update!(status: "cancelled")
  end

  # Update statuses based on the current time
  def self.update_statuses_by_time
    Rails.logger.info "Updating mock interview statuses at #{Time.current}"

    # Only check mock interviews with check_date_time today
    today_start = Time.current.beginning_of_day
    today_end = Time.current.end_of_day

    scope = where(check_date_time: today_start..today_end)

    # Cancel pending interviews
    cancelled_interviews = scope.where(status: "pending")
                                .where("check_date_time < ?", Time.current - 10.minutes)
    cancelled_interviews.update_all(status: "cancelled", updated_at: Time.current)

    Rails.logger.info "Cancelled #{cancelled_interviews.size} interviews: #{cancelled_interviews.pluck(:id)}"

    # Mark accepted interviews as completed
    completed_interviews = scope.where(status: "accepted")
                                .where("check_date_time < ?", Time.current - 1.hour)
    completed_interviews.update_all(status: "completed", updated_at: Time.current)

    Rails.logger.info "Completed #{completed_interviews.size} interviews: #{completed_interviews.pluck(:id)}"
  end
  

  private
  
  def start_time_in_future
    Rails.logger.debug("Check if start time is called")

    return if start_date.blank? || start_time.blank?
    
    now = Time.current

    Rails.logger.debug("Check Date Time: #{check_date_time }")
    Rails.logger.debug("Check Now: #{now}")

    # Validate that the start time is at least 30 minutes in the future
    if check_date_time < now + 30.minutes
      errors.add(:start_time, "must be at least 30 minutes from now")
    end
  end

  # Determine if the validation should run
  def validate_start_time?
    new_record? || status == "accepted"
  end


  
end
