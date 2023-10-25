# frozen_string_literal: true
module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorized, except: [:create]
      before_action :set_user, only: %i[show update destroy]

      def index
        @users = User.all

        render json: @users
      end

      def show
        render json: @user
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: { status: 'User created successfully' }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @user = User.find_by(id: params[:id])

        return render json: { errors: 'Usuário inexistente' }, status: :not_found if @user.nil?

        @service = User::UpdateService.new(@user, user_params)

        if @service.call
          render json: { message: 'Usuário Atualizado' }, status: :ok
        else
          render json: { errors: @service.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:name, :email, :password)
      end
    end
  end
end
