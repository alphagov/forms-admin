class Reports::ContactForResearchService
  def contact_for_research_data
    {
      caption: I18n.t("reports.contact_for_research.heading"),
      head: [
        { text: I18n.t("reports.contact_for_research.table_headings.name") },
        { text: I18n.t("reports.contact_for_research.table_headings.email") },
        { text: I18n.t("reports.contact_for_research.table_headings.date_added") },
      ],
      rows:,
    }
  end

private

  def rows
    as_data_rows(user_contact_for_research)
  end

  def as_data_rows(raw_data)
    raw_data.map do |name, email, user_research_opted_in_at|
      [{ text: name }, { text: email }, { text: user_research_opted_in_at.to_formatted_s(:long) }]
    end
  end

  def user_contact_for_research
    User.research_contact_consented.order(user_research_opted_in_at: :desc).pluck(:name, :email, :user_research_opted_in_at)
  end
end
