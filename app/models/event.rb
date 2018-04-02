class Event < ActiveRecord::Base
  def self.event_import_xls(filepath, num)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet.open(filepath)
    sheet1 = book.worksheet(num)
    sheet1.each 1 do |row|
      next if row[0] == 'Category' || row[0] == ''
      return true if row.empty?
      root = Event.create(category: row[0],
                          function_area: row[1],
                          function_level: row[2],
                          category_m: row[3],
                          # event_id: row[4],
                          steps: row[5],
                          jelly_bean: row[6],
                          grl: row[7],
                          event_level: row[8],
                          regression_level: row[9],
                          expected_result: row[10])
    end
  end

  def self.trans_by_baidu
    # 加载翻译账号信息
    appid = $settings[:baidu]['appid']
    key = $settings[:baidu]['key']
    salt = $settings[:baidu]['salt']
    url = $settings[:baidu]['url']

    events = Event.all
    events.each do |event|
      next if event.expected_result == 'N/A'
      begin
        expected_result_str = "#{appid}#{event.expected_result}#{salt}#{key}"
        expected_result_sign = Digest::MD5.hexdigest expected_result_str

        steps_str = "#{appid}#{event.steps}#{salt}#{key}"
        steps_sign = Digest::MD5.hexdigest steps_str

        steps_params = "q=#{event.steps}&from=en&to=zh&appid=#{appid}&salt=#{salt}&sign=#{steps_sign}"
        expected_result_params = "q=#{event.expected_result}&from=en&to=zh&appid=#{appid}&salt=#{salt}&sign=#{expected_result_sign}"
        steps_request = RestClient.post(url, steps_params)
        expected_result_request = RestClient.post(url, expected_result_params)
        event.expected_result = JSON.parse(expected_result_request)["trans_result"]&.first["src"].to_s + "\n" +JSON.parse(expected_result_request)["trans_result"]&.first["dst"].to_s
        event.steps = JSON.parse(steps_request)["trans_result"]&.first["src"].to_s + "\n" +JSON.parse(steps_request)["trans_result"]&.first["dst"].to_s

        puts "steps:" + event.steps + "\n" + "expected_result: " + event.expected_result
        puts '正在翻译第' + event.id.to_s + '条'
        event.save
        sleep 1
      rescue Exception => e
        puts '第' + event.id.to_s + '条翻译失败！'
      end
    end
    puts '翻译完成'
  end

  def self.export_events
    xls_report = StringIO.new
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "backup"
    # sheet1.row(0).concat ["Category", "Function Area", "Function Level", "Category", "Event ID", "Steps", "Jelly Bean","GRL","Event Level","Regression Level", "Expected Result"]
    sheet1.row(0).concat ["Category", "Function Area", "Function Level", "Type", "Steps", "Jelly Bean","GRL","Event Level","Regression Level", "Expected Result"]
    format = Spreadsheet::Format.new :weight => :bold, :size => 14
    # format1 = Spreadsheet::Format.new :weight => :bold, :size => 14
    sheet1.row(0).default_format = format

    sheet1.column(0).width = 15
    sheet1.column(1).width = 15
    sheet1.column(2).width = 15
    sheet1.column(3).width = 15
    sheet1.column(4).width = 15
    sheet1.column(5).width = 50
    sheet1.column(6).width = 15
    sheet1.column(7).width = 15
    sheet1.column(8).width = 15
    # sheet1.column(9).width = 15
    sheet1.column(9).width = 100


    Event.all.each_with_index do |event, index|
      sheet1.row(index+2).concat [event.category,
                                  event.function_area,
                                  event.function_level,
                                  event.category_m,
                                  # event.event_id,
                                  event.steps.to_s,
                                  event.jelly_bean,
                                  event.grl,
                                  event.event_level,
                                  event.regression_level,
                                  event.expected_result.to_s]

    end
    book.write xls_report
    xls_report.string
  end
end
