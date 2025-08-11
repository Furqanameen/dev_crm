class ImportBatchPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? && (record.user == user || super_admin?)
  end

  def create?
    admin?
  end

  def update?
    admin? && (record.user == user || super_admin?)
  end

  def destroy?
    super_admin?
  end

  def mapping?
    admin? && record.user == user
  end

  def preview?
    admin? && record.user == user
  end

  def perform?
    admin? && record.user == user
  end

  def download_errors?
    admin? && (record.user == user || super_admin?)
  end

  def download_processed?
    admin? && (record.user == user || super_admin?)
  end

  def status?
    admin? && (record.user == user || super_admin?)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user&.admin?
      
      if user.super_admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
