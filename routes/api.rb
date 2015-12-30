require 'mechanize'
require 'nokogiri'

class Api < Cuba
  define do
    on 'services' do
      on get, root do
        resp = { services: ['bjds', 'lngs', 'lnds'] }
        json resp, status: 200
      end
    end

    on 'lngs' do

      verify_url = 'http://wsbst.tax.ln.cn/fpxgxx.do?service=fpxgxxService&method=getResult'

      on get do
        resp = { fields: [fpdm: '发票代码', 
                          fphm: '发票号码',
                          nsrsbh: '纳税人识别号',
                          nsrmc: '纳税人名称'
                          ] }
        json resp, status: 200
      end

      on post do
        # application/json
        if req.content_type.include? 'json'
          puts "JSON REQ"
          # puts req.body.read.class
          req_hash = JSON.parse req.body.read
        else
          # application/x-www-form-urlencoded
          # multipart/form-data
          puts "FORM REQ"
          req_hash = slice(req.params, :fpdm, :fphm, :nsrsbh, :nsrmc)
        end
          puts req_hash
          fpdm = req_hash['fpdm']
          fphm = req_hash['fphm']
          nsrsbh = req_hash['nsrsbh']
          nsrmc = req_hash['nsrmc']

          agent = Mechanize.new

          data = {
            "nsrsbh" => nsrsbh, 
            "nsrmc" => nsrmc.encode('GBK'),
            "fpdm" => fpdm,
            "fphm" => fphm 
          }

          result_page = agent.post(verify_url, data).body.encode("UTF-8", "GBK")
          result = Nokogiri::HTML.parse(result_page).css("#result").text
          # render("result", title: "验证结果", content: result)
          puts result
          json({status: 'ok', result: result}, status: 200)
      end
    end
  end
end