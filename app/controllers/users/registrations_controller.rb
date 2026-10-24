# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    guest_user = current_guest

    # ユーザー登録前はゲストが必ず存在する仕様の為
    raise ActiveRecord::RecordNotFound, "GuestUser not found" unless guest_user

    signup_events = []
    registration_succeeded = false

    ApplicationRecord.transaction do
      super do |resource|
        unless resource.persisted?
          flash.now[:alert] = t("devise.registrations.invalid")
          next
        end

        user_status = Users::TransferGuestData.new(
          guest_user: guest_user,
          user: resource
        ).call

        signup_events = user_status.record_signup!
        registration_succeeded = true
      end
    end

    return unless registration_succeeded
    add_status_events(signup_events)
    cookies.delete(:guest_token)
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    super do |resource|
      if resource.errors.any?
        flash.now[:alert] = t("devise.registrations.update_failed")
      end
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    mypage_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    mypage_path
  end

  # アカウント削除後の遷移先を定義
  def after_sign_out_path_for(resource)
    new_user_registration_path
  end
end
