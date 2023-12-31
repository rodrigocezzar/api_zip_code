# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    context 'verify authorization' do
      let(:url) { "#{base_url}/users" }

      it 'return 401 status if user is not logged in' do
        get url
        expect(response).to custom_have_http_status(401)
      end
    end

    context 'with no pagination params' do
      let(:url) { "#{base_url}/users" }
      let(:current_user) { create(:user) }
      let!(:users) { create_list(:user, 20) }

      it 'returns the first page of users' do
        get url, headers: login_as(current_user)
        expect(response).to custom_have_http_status(200)
      end
    end

    context 'with pagination params exceeding total pages' do
      let(:url) { "#{base_url}/users" }
      let(:current_user) { create(:user) }
      let!(:users) { create_list(:user, 20) }

      it 'returns the last page of users' do
        get url, headers: login_as(current_user), params: { page: 6 }
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /users/:id' do
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:user) { create(:user) }
    let(:url) { "#{base_url}/users/#{user.id}" }
    let(:other_user) { create(:user) }
    let(:other_url) { "#{base_url}/users/#{user.id}" }

    context 'verify authorization' do
      it 'return 401 status if user is not logged in' do
        get url
        expect(response).to custom_have_http_status(401)
      end
    end

    it 'assigns the requested user to @user' do
      get url, headers: login_as(current_user)
      expect(assigns(:user)).to match_array([user])
    end
  end

  describe 'PUT /users/:id' do
    let(:current_user) { create(:user) }

    context 'verify authorization' do
      let(:params) { { user: { name: 'Novo Usuario' } } }
      let(:url) { "#{base_url}/users/#{current_user.id}" }

      it 'return 401 status if user is not logged in' do
        put url
        expect(response).to custom_have_http_status(401)
      end
    end

    context 'when the post is successfully updated' do
      let(:params) { { user: { name: 'Novo Usuario' } } }
      let(:url) { "#{base_url}/users/#{current_user.id}" }
      let(:params_body) { { user: params[:user] }.to_json }

      it 'returns a success response' do
        put url, headers: login_as(current_user), params: params_body
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Usuário Atualizado')
      end
    end

    context 'when the post is not found' do
      let(:params) { { id: -1, user: { titulo: 'Novo Usuario' } } }
      let(:url) { "#{base_url}/users/#{params[:id]}" }
      let(:params_body) { { user: params[:user] }.to_json }

      it 'returns an error response' do
        put url, headers: login_as(current_user), params: params_body
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { user: { name: '' } } }
      let(:url) { "#{base_url}/users/#{current_user.id}" }
      let(:params_body) { { user: params[:user] }.to_json }

      it 'returns an error response' do
        put url, headers: login_as(current_user), params: params_body
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end
  end

  describe 'POST /users' do
    let(:url) { "#{base_url}/users" }
    let(:current_user) { create(:user) }

    context 'verify authorization' do
      it 'return 401 status if user is not logged in' do
        post url
        expect(response).to custom_have_http_status(401)
      end
    end

    context 'with valid attributes' do
      let(:valid_attributes) { attributes_for(:user, password: '12345678') }

      it 'creates a new user' do
        expect do
          post url, headers: login_as(current_user), params: { user: valid_attributes }.to_json
        end.to change(User, :count).by(2)
      end

      it 'returns 204 after create' do
        post url, headers: login_as(current_user), params: { user: valid_attributes }.to_json
        expect(response).to custom_have_http_status(201)
      end
    end
  end

  describe 'GET /delete' do
    let(:current_user) { create(:user) }
    let!(:user) { create(:user) }
    let(:url) { "#{base_url}/users/#{user.id}" }

    it 'deletes the user' do
      expect do
        delete url, headers: login_as(current_user)
      end.to change(User, :count).by(0)
    end

    context 'verify authorization' do
      it 'return 401 status if user is not logged in' do
        delete url
        expect(response).to custom_have_http_status(401)
      end
    end
  end
end
