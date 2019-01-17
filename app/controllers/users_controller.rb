class UsersController < ChouetteController

  defaults :resource_class => User

  def invite
    already_existing, user = User.invite(user_params.update(organisation: current_organisation).symbolize_keys)
    if already_existing
      @user = user
      render "new_invitation"
    else
      flash[:notice] = I18n.t('users.new_invitation.success')
      redirect_to [:organisation, user]
    end
  end

  def update
    update! do
      organisation_user_path(@user)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to organisation_path }
    end
  end

  def block
    resource.lock_access!
    redirect_to :back
  end

  def unblock
    resource.unlock_access!
    redirect_to :back
  end

  def reinvite
    resource.invite!
    flash[:notice] = t('users.actions.reinvite_flash')
    redirect_to :back
  end

  def reset_password
    resource.send_reset_password_instructions
    flash[:notice] = t('users.actions.reset_password_flash')
    redirect_to :back
  end

  private
  def user_params
    keys = %i[name profile]
    keys << :email unless params[:action] == 'update'
    params.require(:user).permit(*keys)
  end

  def resource
    @user = super.decorate
  end
end
