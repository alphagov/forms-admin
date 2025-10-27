module Forms
  class TranslationsController < WebController
    after_action :verify_authorized

    def new; end
  end
end
