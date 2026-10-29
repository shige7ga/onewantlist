class MemosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_memo, only: %i[ show update ]

  def show
  end

  def update
    if @memo.update(memo_params)
      head :ok
    else
      render json: { error: @memo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_memo
    @memo = current_user.memo || current_user.build_memo
  end

  def memo_params
    params.require(:memo).permit(:content)
  end
end
