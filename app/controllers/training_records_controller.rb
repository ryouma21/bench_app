class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training_record, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:show,:edit, :update, :destroy]

  def new
    @training_record = TrainingRecord.new(training_date: Date.current)
  end

  def index
    @training_records = current_user.training_records.order(training_date: :desc)
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

    # total_volume を自動計算するなら
    if @training_record.valid?
      @training_record.total_volume = 
        @training_record.weight * @training_record.reps * @training_record.sets
    end    

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
    params.require(:training_record).permit(:training_date, :weight, :reps, :sets, :fatigue_level, :advice)
  end
end
