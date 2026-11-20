class WantsController < ApplicationController
  before_action :check_guest_registration_limit, only: :new
  before_action :redirect_if_want_registered_today, only: :new
  before_action :set_want, only: %i[ show edit update destroy update_status ]

  def show
  end

  def new
    @want = current_owner.wants.new
    @status = current_owner.user_status
  end

  def create
    source = registration_source

    unless source
      redirect_to owner_home_path, alert: "登録情報が不正です。もう一度操作してください"
      return
    end

    result = Wants::Register.new(
      owner: current_owner,
      attributes: want_params,
      source: source
    ).call

    @want = result.want

    case result.error
    when nil
      session.delete(:random_want_id) if source == :gacha
      add_status_events(result.events)

      redirect_to owner_home_path,
                  notice: t("defaults.flash_message.created",
                            item: Want.model_name.human)

    when :already_registered
      redirect_to owner_home_path,
                  alert: "今日は既にやりたいことを登録完了しています"

    when :guest_limit
      redirect_to_guest_limit_modal(:direct)

    else
      flash.now[:alert] = t("defaults.flash_message.not_created",
                            item: Want.model_name.human)

      if source == :gacha
        render "random_wants/edit", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    if @want.update(want_params)
      redirect_to want_path(@want), notice: t("defaults.flash_message.updated", item: Want.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_updated", item: Want.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @want.destroy!
    redirect_to owner_home_path, notice: t("defaults.flash_message.deleted", item: Want.model_name.human), status: :see_other
  end

  def update_status
    updated = @want.update(want_status_params)
    @want.reload unless updated

    # 更新成功後に最新の完了数を取得
    @completed_wants_count = current_owner.wants.completed.count if updated

    flash_message = updated ? "ステータスを更新しました" : "ステータスを更新できませんでした"
    flash_type = updated ? :notice : :alert

    respond_to do |format|
      format.turbo_stream do
        flash.now[flash_type] = flash_message
        unless updated
          render :update_status, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def registration_source
    case params[:registration_source]
    when "direct"
      :direct
    when "gacha"
      :gacha if session[:random_want_id].present?
    end
  end

  def check_guest_registration_limit
    return if user_signed_in?
    return if current_owner.direct_registration_available?

    redirect_to_guest_limit_modal(:direct)
  end

  def record_guest_registration!
    return if user_signed_in?
    return unless registration_source == :direct

    current_owner.record_direct_registration!
  end

  def want_params
    params.require(:want).permit(:content, :status, :due_date)
  end

  def want_status_params
    params.require(:want).permit(:status)
  end

  def set_want
    @want = current_owner.wants.find_by(id: params[:id])
    return if @want.present?
    redirect_to owner_home_path, alert: t("defaults.flash_message.unauthenticated")
  end
end
