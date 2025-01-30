class CareerDataController < ApplicationController
  def show

  end

  def overview
    

  end

  def change
    @partial = params[:partial] || "change_from_table" # Default partial
  end

  def start
    # @partial = params[:partial] || "change_from_table" # Default partial
  end


  def nodes_data
    # Define static nodes with their correct IDs
    node_mapping = [
      { id: 1, name: "Analyst", level: 1, industry: "Venture Capital" },
      { id: 2, name: "Associate", level: 2, industry: "Venture Capital" },
      { id: 6, name: "Analyst", level: 1, industry: "Private Equity" },
      { id: 7, name: "Associate", level: 2, industry: "Private Equity" },
      { id: 16, name: "Analyst", level: 1, industry: "Investment Banking" },
      { id: 17, name: "Associate", level: 2, industry: "Investment Banking" }
      # Add more nodes as needed...
    ]
  
    # Fetch and group compensation data from the database
    grouped_compensations = CareerCompensation
      .joins(:career_job)
      .group("career_jobs.industry", "career_compensations.level")
      .select(
        "career_jobs.industry AS industry",
        "career_compensations.level AS level",
        "COUNT(*) AS record_count",
        "AVG(career_compensations.salary) AS avg_salary",
        "AVG(career_compensations.bonus) AS avg_bonus",
        "AVG(career_compensations.salary + career_compensations.bonus) AS avg_total_comp",
        "AVG((career_compensations.salary + career_compensations.bonus) / NULLIF(career_compensations.hours_worked_per_week, 0)) AS avg_comp_per_hour"
      )
  
    # Fetch and group aggregate data
    grouped_aggregate = CareerAggregateJob
      .group(:industry, :level)
      .select(
        :industry,
        :level,
        "SUM(sample_size) AS total_sample_size",
        "SUM(sample_size * average_salary) AS weighted_salary",
        "SUM(sample_size * average_bonus) AS weighted_bonus",
        "SUM(sample_size * (average_salary + average_bonus)) AS weighted_total_comp",
        "SUM(sample_size * (average_salary + average_bonus) / NULLIF(average_hours_worked_per_week, 0)) AS weighted_comp_per_hour"
      )
  
    # Match backend data to existing static node IDs
    nodes = node_mapping.map do |node|
      # Find individual record data
      individual_data = grouped_compensations.find { |comp| comp.industry == node[:industry] && comp.level == node[:name] }
  
      # Find aggregate data
      aggregate_data = grouped_aggregate.find { |agg| agg.industry == node[:industry] && agg.level == node[:name] }
  
      # Calculate total record count
      individual_record_count = individual_data&.record_count || 0
      aggregate_sample_size = aggregate_data&.total_sample_size.to_i
      total_records = individual_record_count + aggregate_sample_size
  
      # Calculate weighted averages
      avg_salary = if total_records > 0
                     (
                       (individual_data&.avg_salary.to_f * individual_record_count) +
                       aggregate_data&.weighted_salary.to_f
                     ) / total_records
                   else
                     0
                   end
  
      avg_bonus = if total_records > 0
                    (
                      (individual_data&.avg_bonus.to_f * individual_record_count) +
                      aggregate_data&.weighted_bonus.to_f
                    ) / total_records
                  else
                    0
                  end
  
      avg_total_comp = if total_records > 0
                         (
                           (individual_data&.avg_total_comp.to_f * individual_record_count) +
                           aggregate_data&.weighted_total_comp.to_f
                         ) / total_records
                       else
                         0
                       end
  
      avg_comp_per_hour = if total_records > 0
                            (
                              (individual_data&.avg_comp_per_hour.to_f * individual_record_count) +
                              aggregate_data&.weighted_comp_per_hour.to_f
                            ) / total_records
                          else
                            0
                          end
  
      # Build the node data
      {
        id: node[:id],                      # Use the existing static node ID
        name: node[:name],                  # Keep the level name
        level: node[:level],                # Keep level ranking
        industry: node[:industry],          # Keep industry name
        record_count: total_records,        # Total number of records (individual + aggregate)
        avg_salary: avg_salary.round(2),    # Weighted average salary
        avg_bonus: avg_bonus.round(2),      # Weighted average bonus
        avg_total_comp: avg_total_comp.round(2), # Weighted average total compensation
        avg_comp_per_hour: avg_comp_per_hour.round(2) # Weighted average compensation per hour
      }
    end
  
    render json: nodes
  end

  def link_data
    # Step 1: Fetch career jobs with their associated compensation levels
    grouped_jobs = CareerJob
      .joins(:career_compensations) # Join with career_compensations table
      .select(
        "career_jobs.id", 
        "career_jobs.job_grouping", 
        "career_jobs.job_order", 
        "career_jobs.industry", 
        "career_compensations.level AS level" # Fetch level from career_compensations
      )
      .where.not(job_grouping: nil, job_order: nil) # Only consider rows with valid grouping and order
      .order(:job_grouping, :job_order)            # Ensure proper ordering within grouping
  
    # Step 2: Build links
    links = []
    grouped_jobs.group_by(&:job_grouping).each do |grouping, jobs|
      jobs.each_cons(2) do |from_job, to_job|
        # Skip if the industry and level are the same
        next if from_job.industry == to_job.industry && from_job.level == to_job.level
  
        # Add a valid link
        links << {
          source: from_job.id,
          target: to_job.id,
          avg_salary: calculate_link_data(to_job, from_job)[:source_avg_salary],
          avg_bonus: calculate_link_data(to_job, from_job)[:source_avg_bonus],
          avg_total_comp: calculate_link_data(to_job, from_job)[:source_avg_salary] + calculate_link_data(to_job, from_job)[:source_avg_bonus],
          avg_comp_per_hour: calculate_link_data(to_job, from_job)[:source_avg_comp_per_hour]
        }
      end
    end
  
    # Step 3: Return links as JSON
    render json: links
  end
  
  
  
  # Helper method to calculate link-specific data
  def calculate_link_data(to_job, from_job)
    # Fetch average compensation data for the jobs in this link
    career_compensations = CareerCompensation
      .where(career_job_id: [to_job.id, from_job.id])
      .group(:career_job_id)
      .select(
        :career_job_id,
        "AVG(salary) AS avg_salary",
        "AVG(bonus) AS avg_bonus",
        "AVG(hours_worked_per_week) AS avg_hours_worked_per_week",
        "AVG((salary + bonus) / NULLIF(hours_worked_per_week, 0)) AS avg_comp_per_hour"
      )
  
    # Extract data for the source and target jobs
    source_data = career_compensations.find { |c| c.career_job_id == from_job.id } || {}
    target_data = career_compensations.find { |c| c.career_job_id == to_job.id } || {}
  
    {
      source_avg_salary: source_data[:avg_salary].to_f.round(2),
      source_avg_bonus: source_data[:avg_bonus].to_f.round(2),
      source_avg_hours_worked_per_week: source_data[:avg_hours_worked_per_week].to_i,
      source_avg_comp_per_hour: source_data[:avg_comp_per_hour].to_f.round(2),
  
      target_avg_salary: target_data[:avg_salary].to_f.round(2),
      target_avg_bonus: target_data[:avg_bonus].to_f.round(2),
      target_avg_hours_worked_per_week: target_data[:avg_hours_worked_per_week].to_i,
      target_avg_comp_per_hour: target_data[:avg_comp_per_hour].to_f.round(2)
    }
  end
  
  

end
