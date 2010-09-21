class Nagios

  class << self
    def status
      doc = open(NAGIOS_URL, :http_basic_authentication => [NAGIOS_USER, NAGIOS_PW]) { |f| Hpricot(f) }

      problems = doc.
        search("table.status > tr")[1..-1].
        select { |problem| problem.search("> td").size > 1 }.
        select { |problem| problem.search("img[@src $= 'ack.gif']").size == 0 && problem.search("img[@src $= 'ndisabled.gif']").size == 0 }

      {
        :system_count => doc.search("table.serviceTotals").at("td.serviceTotalsOK").inner_html.to_i,
        :problem_count => problems.size,
        :critical_count => problems.grep(/^C:/).size,
        :problems => problems.map { |problem|
          "#{problem.search("> td")[1].inner_text.strip} (#{problem.search("> td")[0].inner_text.strip})"
        }
      }
    end
  end
end
