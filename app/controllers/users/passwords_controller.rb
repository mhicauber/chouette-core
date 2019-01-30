class Users::PasswordsController < Devise::PasswordsController

  skip_after_action :set_creator_metadata

  def create
    user = User.find_by email: params[:user][:email]

    if user && user.blocked?
      redirect_to "/", notice: 'users.locked'.t
      return
    end

    super
  end
end
