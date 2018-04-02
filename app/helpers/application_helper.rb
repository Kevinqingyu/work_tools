module ApplicationHelper
  # 显示序号
  def index_no(index, per = 20)
    params[:page] ||= 1
    (params[:page].to_i - 1) * per + index + 1
  end
end
