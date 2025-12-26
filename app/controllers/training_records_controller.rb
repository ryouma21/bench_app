class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training_record, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:show,:edit, :update, :destroy]

  def new
    @training_record = TrainingRecord.new(
      training_date: Date.current,
      weight: params[:weight],
      reps:   params[:reps],
      sets:   params[:sets],
      set_type: params[:set_type]
    )
  end

  def index
    @training_records = current_user.training_records.order(training_date: :desc, created_at: :desc)

    # 1RMの配列（nilを除外）
    @one_rm_values = @training_records.map { |r| r.estimated_one_rm }.compact

    # 日付の配列（グラフの横軸）
    @one_rm_dates = @training_records.map { |r| r.training_date.strftime("%Y/%m/%d") }

    @weekly_volume = TrainingRecord.weekly_volume(current_user)
  end

  def show
  end

  def edit
  end

  def update
    if @training_record.update(training_record_params)
      redirect_to training_record_path(@training_record), notice: "記録を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @training_record.destroy
    redirect_to training_records_path, notice: "記録を削除しました。"
  end


  def create
    @training_record = current_user.training_records.new(training_record_params) 

    if @training_record.save
      redirect_to training_records_path, notice: "記録を保存しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_training_record
    @training_record = TrainingRecord.find(params[:id])
  end

   def correct_user
    redirect_to root_path unless @training_record.user == current_user
  end

  def training_record_params
    params.require(:training_record).permit(:training_date, :weight, :reps, :sets, :fatigue_level, :advice, :set_type, :menu_type)
  end
end
