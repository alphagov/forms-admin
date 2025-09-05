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
    raw_data.map do |name, email, created_at|
      [{ text: name }, { text: email }, { text: created_at.to_date.to_formatted_s }]
    end
  end

  def user_contact_for_research
    User.research_contact_consented.order(created_at: :desc).pluck(:name, :email, :created_at)
  end
end
