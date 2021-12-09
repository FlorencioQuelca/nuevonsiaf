class Ability
  include CanCan::Ability

  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    if user.is_super_admin?
      can :manage, :all
    elsif user.is_admin? # Responsable Activos fijos
      can :manage, Supplier
      can :manage, Building
      can :manage, Department
      can :manage, User
      cannot [:update], User, User.all do |usuario|
        %w(super_admin admin_store).include?(usuario.role)
      end
      can :manage, Account
      can :manage, Auxiliary
      can :manage, Asset
      can :manage, Ingreso
      can :manage, Proceeding
      can [:index, :account, :asset, :auxiliary, :obt_cod_barra, :pdf], :barcode
      can :manage, Version
      can :manage, NoteEntry
      can :manage, Ubicacion
      can :manage, Ufv
      can :manage, Gestion
      can :manage, Baja
      can :manage, Seguro
      cannot [:update], Gestion, cerrado: true
    elsif user.is_admin_store? # Responsable de almacenes
      can [:welcome, :show, :update], User, id: user.id
      can [:departments, :users], Asset
      can :manage, Supplier
      can :manage, Material
      can :manage, Request
      can :manage, Subarticle
      can :manage, NoteEntry
      can :manage, EntrySubarticle
      can :manage, Building
      can :manage, Department
      can :manage, User
      cannot [:update], User, User.all do |usuario|
        %w(super_admin admin).include?(usuario.role)
      end
      can :manage, Version
      can :manage, Transaccion
    elsif user.is_observador_almacen? # Observador de sólo lectura
      can [:welcome, :show], User, id: user.id
      can [:departments, :users], Asset
      can :read, Supplier
      can [:read, :reports], Material
      can :read, Request
      can :read, Subarticle
      can :read, NoteEntry
      can :read, EntrySubarticle
      can :read, Building
      can :read, Department
      can :read, User
      can :read, Version
    else
      can [:show, :update], User, id: user.id
      can :index, :welcome
    end
  end
end
