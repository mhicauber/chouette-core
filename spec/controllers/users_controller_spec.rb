RSpec.describe UsersController, :type => :controller do

  let(:organisation) { @user.organisation }

  describe "GET edit" do
    let(:request){ get :edit, id: target_user.id }
    let(:target_user)  { create :user }

    it 'should be forbidden' do
      request
      expect(response.status).to eq 302
    end

    context 'logged in' do
      context 'in the same organisation' do
        let(:target_user)  { create :user, organisation: organisation }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            request
            expect(response.status).to eq 200
          end
        end

        context 'on self' do
          let(:target_user)  { @user }

          context 'as visitor' do
            login_user profile: :visitor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as editor' do
            login_user profile: :editor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as admin' do
            login_user profile: :admin
            it 'should be authorized' do
              request
              expect(response.status).to eq 200
            end
          end
        end
      end

      context 'in a different organisation' do
        let(:target_user)  { create :user, organisation: create(:organisation) }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end

  describe "POST update" do
    let(:request){ post :update, id: target_user.id, user: { foo: :bar } }
    let(:target_user)  { create :user }

    it 'should be forbidden' do
      request
      expect(response.status).to eq 302
    end

    context 'logged in' do
      context 'in the same organisation' do
        let(:target_user)  { create :user, organisation: organisation }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            request
            expect(response.status).to eq 302
          end
        end

        context 'on self' do
          let(:target_user)  { @user }

          context 'as visitor' do
            login_user profile: :visitor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as editor' do
            login_user profile: :editor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as admin' do
            login_user profile: :admin
            it 'should be authorized' do
              request
              expect(response.status).to eq 302
            end
          end
        end
      end

      context 'in a different organisation' do
        let(:target_user)  { create :user, organisation: create(:organisation) }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end

  describe "DELETE destroy" do
    let(:request){ delete :destroy, id: target_user.id }
    let(:target_user)  { create :user }

    it 'should be forbidden' do
      request
      expect(response.status).to eq 302
    end

    context 'logged in' do
      context 'in the same organisation' do
        let(:target_user)  { create :user, organisation: organisation }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            request
            expect(response.status).to eq 403
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            request
            expect(response.status).to eq 302
          end
        end

        context 'on self' do
          let(:target_user)  { @user }

          context 'as visitor' do
            login_user profile: :visitor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as editor' do
            login_user profile: :editor
            it 'should be forbidden' do
              request
              expect(response.status).to eq 403
            end
          end

          context 'as admin' do
            login_user profile: :admin
            it 'should be authorized' do
              request
              expect(response.status).to eq 403
            end
          end
        end
      end

      context 'in a different organisation' do
        let(:target_user)  { create :user, organisation: create(:organisation) }

        context 'as visitor' do
          login_user profile: :visitor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as editor' do
          login_user profile: :editor
          it 'should be forbidden' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end

        context 'as admin' do
          login_user profile: :admin
          it 'should be authorized' do
            expect{ request }.to raise_error ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end
end
