class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!

  def new
    @training_record = TrainingRecord.new
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

  def training_record_params
    params.require(:training_record).permit(:weight, :reps, :sets, :fatigue_level, :advice, :training_date)
  end
end
