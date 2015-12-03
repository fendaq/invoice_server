require 'open-uri'
require 'mechanize'
require 'nokogiri'

# 该纳税人2015年02月13日购买过此种发票(营改增冠名发票)，还未进行验旧。
# 210105071510462
# 沈阳盛京通有限公司  
# 121011572201
# 02891054

class Lngs < Cuba
  define do
    on default do
      on get do
        render("lngs", title: "辽宁国税") 
      end
      
      on post, param("nsrsbh"), param("nsrmc"), param("fpdm"), param("fphm") do |nsrsbh, nsrmc, fpdm, fphm|
        page_url = 'http://wsbst.tax.ln.cn/fpxgxx.do?service=fpxgxxService&method=init'
        verify_url = 'http://wsbst.tax.ln.cn/fpxgxx.do?service=fpxgxxService&method=getResult'

        agent = Mechanize.new

        data = {
          "nsrsbh" => nsrsbh, 
          "nsrmc" => nsrmc.encode('GBK'),
          "fpdm" => fpdm,
          "fphm" => fphm 
        }

        result_page = agent.post(verify_url, data).body.encode("UTF-8", "GBK")
        result = Nokogiri::HTML.parse(result_page).css("#result").text
        render("result", title: "验证结果", content: result)
      end
    end
  end
end