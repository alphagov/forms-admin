namespace :forms do
  namespace :copied do
    desc "Fix copied form creators where original and copied form creators match (dry run)"
    task fix_creators_dry_run: :environment do
      ActiveRecord::Base.transaction do
        fix_copied_form_creators(dry_run: true)
        raise ActiveRecord::Rollback
      end
    end

    desc "Fix copied form creators where original and copied form creators match"
    task fix_creators: :environment do
      ActiveRecord::Base.transaction do
        fix_copied_form_creators(dry_run: false)
      end
    end
  end
end

def fix_copied_form_creators(dry_run: false)
  updated_count = 0
  skipped_count = 0
  not_found_count = 0

  COPIED_FORMS_DATA.each do |row|
    original_form_id = row[:original_form_id]
    copied_form_id = row[:copied_form_id]
    logged_in_user_id = row[:user_id]

    original_form = Form.find_by(id: original_form_id)
    copied_form = Form.find_by(id: copied_form_id)
    logged_in_user = User.find_by(id: logged_in_user_id)

    if original_form.nil? || copied_form.nil?
      Rails.logger.info "fix_copied_form_creators: Form not found - original: #{original_form_id}, copied: #{copied_form_id}"
      not_found_count += 1
      next
    end

    if logged_in_user.nil?
      Rails.logger.info "fix_copied_form_creators: User not found - user_id: #{logged_in_user_id}"
      not_found_count += 1
      next
    end

    if original_form.creator_id == logged_in_user_id
      Rails.logger.info "fix_copied_form_creators: Skipping #{fmt_form(copied_form)} - logged in user is creator of original form"
      skipped_count += 1
    elsif original_form.creator_id == copied_form.creator_id
      Rails.logger.info "fix_copied_form_creators: Updating #{fmt_form(copied_form)} creator from #{copied_form.creator_id} to #{logged_in_user_id} (#{logged_in_user.email})"
      copied_form.update!(creator_id: logged_in_user_id)
      updated_count += 1
    else
      Rails.logger.info "fix_copied_form_creators: Skipping #{fmt_form(copied_form)} - creators differ (original: #{original_form.creator_id}, copied: #{copied_form.creator_id})"
      skipped_count += 1
    end
  end

  Rails.logger.info "fix_copied_form_creators: Updated: #{updated_count}, Skipped: #{skipped_count}, Not found: #{not_found_count}"
  Rails.logger.info "fix_copied_form_creators: #{dry_run ? 'DRY RUN - changes rolled back' : 'Changes committed'}"
end

def fmt_form(form)
  "form #{form.id} (\"#{form.name}\")"
end

COPIED_FORMS_DATA = [
  { original_form_id: 264_221, copied_form_id: 264_475, user_id: 3949 },
  { original_form_id: 6840, copied_form_id: 264_470, user_id: 2939 },
  { original_form_id: 264_457, copied_form_id: 264_465, user_id: 3950 },
  { original_form_id: 3875, copied_form_id: 264_444, user_id: 24 },
  { original_form_id: 3875, copied_form_id: 264_443, user_id: 24 },
  { original_form_id: 263_380, copied_form_id: 264_437, user_id: 1533 },
  { original_form_id: 6383, copied_form_id: 264_436, user_id: 1533 },
  { original_form_id: 264_427, copied_form_id: 264_434, user_id: 679 },
  { original_form_id: 1899, copied_form_id: 264_427, user_id: 679 },
  { original_form_id: 264_407, copied_form_id: 264_419, user_id: 3958 },
  { original_form_id: 5169, copied_form_id: 264_401, user_id: 22 },
  { original_form_id: 5169, copied_form_id: 264_400, user_id: 22 },
  { original_form_id: 264_389, copied_form_id: 264_399, user_id: 2509 },
  { original_form_id: 264_389, copied_form_id: 264_396, user_id: 2509 },
  { original_form_id: 5171, copied_form_id: 264_395, user_id: 22 },
  { original_form_id: 3875, copied_form_id: 264_394, user_id: 24 },
  { original_form_id: 264_221, copied_form_id: 264_363, user_id: 3951 },
  { original_form_id: 263_948, copied_form_id: 264_361, user_id: 5 },
  { original_form_id: 264_346, copied_form_id: 264_347, user_id: 679 },
  { original_form_id: 264_342, copied_form_id: 264_346, user_id: 679 },
  { original_form_id: 264_342, copied_form_id: 264_345, user_id: 679 },
  { original_form_id: 264_215, copied_form_id: 264_342, user_id: 679 },
  { original_form_id: 264_325, copied_form_id: 264_341, user_id: 679 },
  { original_form_id: 5706, copied_form_id: 264_337, user_id: 1896 },
  { original_form_id: 264_325, copied_form_id: 264_333, user_id: 679 },
  { original_form_id: 264_325, copied_form_id: 264_332, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_325, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_324, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_322, user_id: 679 },
  { original_form_id: 264_309, copied_form_id: 264_319, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_309, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_302, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_300, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_296, user_id: 679 },
  { original_form_id: 264_188, copied_form_id: 264_295, user_id: 679 },
  { original_form_id: 7283, copied_form_id: 264_289, user_id: 84 },
  { original_form_id: 7283, copied_form_id: 264_288, user_id: 84 },
  { original_form_id: 7475, copied_form_id: 264_287, user_id: 3059 },
  { original_form_id: 264_282, copied_form_id: 264_283, user_id: 679 },
  { original_form_id: 264_275, copied_form_id: 264_282, user_id: 679 },
  { original_form_id: 264_215, copied_form_id: 264_281, user_id: 679 },
  { original_form_id: 264_279, copied_form_id: 264_280, user_id: 679 },
  { original_form_id: 264_215, copied_form_id: 264_279, user_id: 679 },
  { original_form_id: 264_215, copied_form_id: 264_275, user_id: 679 },
  { original_form_id: 264_217, copied_form_id: 264_272, user_id: 679 },
  { original_form_id: 264_207, copied_form_id: 264_221, user_id: 3939 },
  { original_form_id: 264_215, copied_form_id: 264_217, user_id: 679 },
  { original_form_id: 264_187, copied_form_id: 264_215, user_id: 679 },
  { original_form_id: 263_948, copied_form_id: 264_201, user_id: 117 },
  { original_form_id: 264_187, copied_form_id: 264_188, user_id: 679 },
  { original_form_id: 264_168, copied_form_id: 264_179, user_id: 2478 },
  { original_form_id: 264_169, copied_form_id: 264_171, user_id: 13 },
  { original_form_id: 7683, copied_form_id: 264_169, user_id: 13 },
  { original_form_id: 264_165, copied_form_id: 264_167, user_id: 13 },
  { original_form_id: 7683, copied_form_id: 264_165, user_id: 13 },
  { original_form_id: 7932, copied_form_id: 264_143, user_id: 2918 },
  { original_form_id: 5739, copied_form_id: 264_124, user_id: 84 },
  { original_form_id: 1994, copied_form_id: 264_113, user_id: 84 },
  { original_form_id: 1994, copied_form_id: 264_112, user_id: 84 },
  { original_form_id: 263_774, copied_form_id: 264_088, user_id: 3307 },
  { original_form_id: 264_035, copied_form_id: 264_087, user_id: 3889 },
  { original_form_id: 6375, copied_form_id: 264_059, user_id: 2617 },
  { original_form_id: 5593, copied_form_id: 264_057, user_id: 539 },
  { original_form_id: 6158, copied_form_id: 264_051, user_id: 2617 },
  { original_form_id: 5150, copied_form_id: 264_044, user_id: 182 },
  { original_form_id: 1740, copied_form_id: 264_035, user_id: 893 },
  { original_form_id: 263_967, copied_form_id: 264_032, user_id: 679 },
  { original_form_id: 262_428, copied_form_id: 264_029, user_id: 3722 },
  { original_form_id: 263_977, copied_form_id: 264_028, user_id: 3866 },
  { original_form_id: 8256, copied_form_id: 264_024, user_id: 117 },
].freeze
