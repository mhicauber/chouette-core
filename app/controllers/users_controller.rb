class UsersController < ChouetteController

  defaults :resource_class => User

  # belongs_to :organisation

  # def create
  #   @user = current_organisation.users.build(user_params)
  #
  #   if @user.valid?
  #     @user.invite!
  #     respond_with @user, :location => organisation_user_path(@user)
  #   else
  #     render :action => 'new'
  #   end
  # end

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
    update! do |success, failure|
      success.html { redirect_to organisation_user_path(@user) }
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
    redirect_to :back
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :profile)
  end

  def resource
    @user = super.decorate
  end
end
