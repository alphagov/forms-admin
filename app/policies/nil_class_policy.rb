class NilClassPolicy
  class Scope
    def initialize(*args); end

    def resolve
      raise Pundit::NotDefinedError, "Cannot scope NilClass"
    end
  end

  def initialize(*args); end

  def can_manage_user?
    false
  end
end
