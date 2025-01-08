# == Schema Information
#
# Table name: employees
#
#  id                  :bigint           not null, primary key
#  flag_comment        :text
#  flagged             :integer          default(0), not null
#  linkedin_url        :string
#  name                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint
#  group_id            :bigint
#  job_level_id        :bigint
#  location_id         :bigint
#  previous_company_id :bigint
#  school_id           :bigint
#
# Indexes
#
#  index_employees_on_company_id           (company_id)
#  index_employees_on_flagged              (flagged)
#  index_employees_on_group_id             (group_id)
#  index_employees_on_job_level_id         (job_level_id)
#  index_employees_on_linkedin_url         (linkedin_url)
#  index_employees_on_location_id          (location_id)
#  index_employees_on_name                 (name)
#  index_employees_on_previous_company_id  (previous_company_id)
#  index_employees_on_school_id            (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (job_level_id => job_levels.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (previous_company_id => companies.id)
#  fk_rails_...  (school_id => schools.id)
#
class Employee < ApplicationRecord
  belongs_to :job_level, optional: true
  belongs_to :company, optional: true
  belongs_to :previous_company, class_name: 'Company', optional: true
  belongs_to :group, optional: true
  belongs_to :location, optional: true
  belongs_to :school, optional: true

  has_many :flags, as: :flaggable, dependent: :destroy

  validates :name, presence: true
  validates :linkedin_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
  validates :flagged, numericality: { only_integer: true }, allow_nil: true
end