module GroupListComponent
  class View < ApplicationComponent
    def initialize(groups:, title:, empty_message: "", show_empty: true)
      super()
      @groups = groups
      @title = title
      @empty_message = empty_message
      @show_empty = show_empty
      @creators = creators
    end

    def creators
      creator_ids = @groups.map(&:creator_id).uniq
      User.where(id: creator_ids)
          .pluck(:id, :name)
          .to_h
    end

    def creator_name(group)
      @creators.fetch(group.creator_id, I18n.t("groups.group_list.created_by_unknown"))
    end
  end
end
