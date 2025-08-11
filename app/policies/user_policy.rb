class UserPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def show?
    super_admin? || record == user
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || record == user
  end

  def destroy?
    super_admin? && record != user
  end

  def invite?
    super_admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user&.admin?
      
      if user.super_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
