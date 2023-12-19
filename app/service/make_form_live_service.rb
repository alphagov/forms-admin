class MakeFormLiveService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(draft_form:)
    @draft_form = draft_form
  end

  def make_live
    @draft_form.make_live!
  end
end
