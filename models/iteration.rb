class Iteration
  include DataMapper::Resource

  property :id, Serial
  property :project_id, Integer
  property :iteration_id, Integer
  property :hours, Integer
  property :income, Integer

  class << self
    def update_iteration(project_id, iteration_id, params)
      all(:project_id => project_id, :iteration_id => iteration_id).destroy
      create :project_id => project_id, :iteration_id => iteration_id, :hours => params[:hours].to_i, :income => params[:income].to_i
    end

    def status_for(status, ids = nil)
      if ids
        iterations = all(:project_id => status[:id], :iteration_id => ids)
        sum = iterations.sum(:hours) || 0

        status.merge!(
          :hours         => sum,
          :average_hours => sum / 4,
          :income        => iterations.sum(:income) || 0
        )
      else
        status.merge!(
          :hours         => 0,
          :average_hours => 0,
          :income        => 0
        )
      end
    end
  end
end
