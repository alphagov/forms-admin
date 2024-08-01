class UsersReportService
  def user_data
    {
      caption: I18n.t("reports.users.heading"),
      head: [
        { text: I18n.t("reports.users.table_headings.organisation_name") },
        { text: I18n.t("reports.users.table_headings.user_count"), numeric: true },
      ],
      rows:,
    }
  end

private

  def rows
    as_data_rows(org_name_user_count)
  end

  def as_data_rows(raw_data)
    raw_data.map do |org_name, count|
      [{ text: org_name || I18n.t("users.index.organisation_blank") },
       { text: count, numeric: true }]
    end
  end

  def org_name_user_count
    User.left_joins(:organisation)
      .group("organisations.id")
      .select("organisations.name, COUNT(users.id) AS user_count")
      .order(Arel.sql("COUNT(users.id) DESC"))
      .order("organisations.name")
      .pluck("organisations.name", "COUNT(users.id)")
  end
end
