class EventsController < ApplicationController
  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.page(params[:page]).per(20)
  end

  def export
    send_data(Event.export_events, :type => "text/excel;charset=utf-8; header=present", :filename => "表格.xls" )
  end

  def import_events

  end

  def trans_to_zh
    Event.trans_by_baidu
  end

  def import
    if params[:excel_data].blank?
      redirect_to :back, notice: '添加文件不能为空'
      return
    end
    Thread.new {
      Event.event_import_xls(params[:excel_data].path, params[:number].to_i)
    }
    redirect_to :back, notice: '正在加速导入中，请稍后！'
  end
end