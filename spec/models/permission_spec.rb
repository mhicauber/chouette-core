RSpec.describe Permission, :type => :model do
  describe 'Profile#update_users_permissions' do
    let!(:admin){ create :user, profile: :admin }
    let!(:visitor){ create :user, profile: :visitor }
    let!(:custom){ create :user, profile: :custom }

    it 'should not change admin permissions' do
      expect { Permission::Profile.update_users_permissions }.to_not change{ admin.reload.permissions }
    end

    it 'should not change visitor permissions' do
      expect { Permission::Profile.update_users_permissions }.to_not change{ visitor.reload.permissions }
    end

    it 'should not change custom permissions' do
      expect { Permission::Profile.update_users_permissions }.to_not change{ custom.reload.permissions }
    end

    context 'when the profile changed' do
      before(:each) do
        Permission::Profile.profile :admin, Permission.full[0..-2]
      end

      it 'should change admin permissions' do
        expect { Permission::Profile.update_users_permissions }.to change{ admin.reload.permissions }
      end

      it 'should not change visitor permissions' do
        expect { Permission::Profile.update_users_permissions }.to_not change{ visitor.reload.permissions }
      end

      it 'should not change custom permissions' do
        expect { Permission::Profile.update_users_permissions }.to_not change{ custom.reload.permissions }
      end
    end
  end

  describe 'Profile#set_users_profiles' do
    let!(:admin){ create :user, profile: :admin }
    let!(:visitor){ create :user, profile: :visitor }
    let!(:custom){ create :user, profile: :custom }

    it 'should not change admin profile' do
      expect { Permission::Profile.set_users_profiles }.to_not change{ admin.reload.profile }
    end

    it 'should not change visitor profile' do
      expect { Permission::Profile.set_users_profiles }.to_not change{ visitor.reload.profile }
    end

    it 'should not change custom profile' do
      expect { Permission::Profile.set_users_profiles }.to_not change{ custom.reload.profile }
    end

    context 'when the users don\'t have their profile set' do
      before(:each) do
        admin.update_column :profile, nil
        visitor.update_column :profile, nil
        custom.update_column :profile, nil
      end

      it 'should change admin permissions' do
        expect { Permission::Profile.set_users_profiles }.to_not change{ admin.reload.permissions }
        expect(admin.profile).to eq 'admin'
      end

      it 'should not change visitor permissions' do
        expect { Permission::Profile.set_users_profiles }.to_not change{ visitor.reload.permissions }
        expect(visitor.profile).to eq 'visitor'
      end

      it 'should not change custom permissions' do
        expect { Permission::Profile.set_users_profiles }.to_not change{ custom.reload.permissions }
        expect(custom.profile).to eq 'custom'
      end
    end
  end
end
