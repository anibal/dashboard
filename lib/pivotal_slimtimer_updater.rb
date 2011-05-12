require 'lib/slimtimer_api'

class PivotalSlimtimerUpdater
	def initialize(project, xml)
		@project = project

    doc 		 = Nokogiri::XML.parse(xml)
    @stories = doc.xpath(".//story")
  end

  def valid?
		true
  end

  def update
		@stories.each do |story|
			id 	 = story.xpath(".//id").text
      name = "#{@project.slimtimer[:task_prefix]} #{id}"

      case story.xpath(".//current_state").text
      when "started"
        create_slimtimer_task name
      when "delivered"
        finish_slimtimer_task name
      end
		end
  end

  def create_slimtimer_task(name)
    slimtimer_api.create_task name, "trike"
  end

  def finish_slimtimer_task(name)
		new_tasks = slimtimer_api.tasks(0, "no", "owner")
    SlimtimerTask.update(new_tasks)

    SlimtimerTask.all(:name => name).each do |task|
      slimtimer_api.finish_task task.id, name
    end
  end

private

	def slimtimer_api
		@st_api = ::SlimtimerApi.new(SLIMTIMER_APIKEY)
  end
end
