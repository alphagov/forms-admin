class TaskStatusService
  def initialize(form:)
    @form = form
  end

  def statuses
    name_status = :completed

    pages_status = if @form.question_section_completed && @form.pages.any?
                     :completed
                   elsif @form.pages.any?
                     :in_progress
                   else
                     :incomplete
                   end

    declaration_status = if @form.declaration_section_completed
                           :completed
                         else
                           :incomplete
                         end

    what_happens_next_status = if @form.what_happens_next_text.present?
                                 :completed
                               else
                                 :incomplete
                               end

    submission_email_status = if @form.submission_email.present?
                                :completed
                              else
                                :incomplete
                              end

    privacy_policy_status = if @form.privacy_policy_url.present?
                              :completed
                            else
                              :incomplete
                            end

    support_contact_details_status = if @form.support_email.present? || @form.support_phone.present? || (@form.support_url_text.present? && @form.support_url)
                                       :completed
                                     else
                                       :incomplete
                                     end

    make_live_status = if [pages_status,
                           what_happens_next_status,
                           submission_email_status,
                           privacy_policy_status,
                           support_contact_details_status].all? { |task| task == :completed }
                         :not_started
                       else
                         :cannot_start
                       end

    { name_status:, pages_status:, declaration_status:, what_happens_next_status:, submission_email_status:, privacy_policy_status:, support_contact_details_status:, make_live_status: }
  end

  def is_complete?(task)
    statuses[task] == :completed
  end
end
