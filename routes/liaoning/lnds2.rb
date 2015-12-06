# 辽宁地税_自动验证
require 'open-uri'
require 'mechanize'
require 'nokogiri'

# 流程:

# 1. 先请求验证码图片 chkNum.jpg (后面带日期时间，测试发现不带也可以)
#
# 2. 在同一个 session 里请求 auto.jsp
# 返回 XML: <response><yzmxx>XXXX</yzmxx></response> 里面的 XXXX 就是正确的验证码
# (估计是一个预留的自动化接口吧)
#
# 3. 同一个 session POST 到验证地址, data 结构:
# "fpdm1" : "221011270132",
# "fphm1" : "08248414",
# "TABLE_ACTION" : "display",
# "TABLE_NAME" : "FP_ZWCX",
# "checkNum" : 验证码 
#
# 4. 返回的页面 (GBK编码) 中 <form name="sbcx_form"><table> 里就是结果信息

# 前三位为221,第四、五位为非02(大连)、第六、七位大于等于07(年份)

# 发票代码 221011270132
# 发票号码 08248414

# return
# 购票日期 2012-09-27
# 发票种类 微机发票
# 纳税人名称 沈阳市皇姑区韩宝斋京都铜火锅店 
# 发票名称 辽宁省地方税务统一发票(3联) 
# 票面金额 * 
# 发售税务机关 沈阳市皇姑区地方税务局征收科
# 发票状态 正常发票  

class Lnds2 < Cuba
  define do
    captcha_img = 'http://fpcx.lnsds.gov.cn/CheckNumImg/chkNum.jpg'
    captcha_url = 'http://fpcx.lnsds.gov.cn/jsp/fpzwcx/auto.jsp'
    verify_url = 'http://fpcx.lnsds.gov.cn/FpzwcxServlet'

    on 'captcha' do
      on get do
        agent = Mechanize.new
        agent.get(captcha_img) do |captcha|
          if captcha.code = '200'
            res.headers["Content-Type"] = "image/jpeg"
            res.write captcha.body
          else
            # 验证码错误
          end
        end
      end
    end

    on default do
      on get do
        render("lnds", title: "辽宁地税")
      end
      # 自动验证
      on post, param("fpdm"), param("fphm") do |fpdm, fphm|
        agent = Mechanize.new
        agent.get(captcha_img) do |img|
          agent.get(captcha_url) do |captcha|
            if captcha.code == "200"
              cap = Nokogiri::XML.parse(captcha.body).xpath("//response/yzmxx")
              if cap.text == "null"
                render("result", title: "验证码获取失败", content: "验证码获取失败，请重试")
              else
                data = {
                  "fpdm1" => fpdm,
                  "fphm1" => fphm,
                  "TABLE_ACTION" => "display",
                  "TABLE_NAME" => "FP_ZWCX",
                  "checkNum" => cap.text
                }
                result_page = agent.post(verify_url, data).body.encode("UTF-8", "GBK")
                render("result", title: "验证结果", content: Nokogiri::HTML.parse(result_page).css("form[name=sbcx_form] table").first)
              end
            end
          end 
        end
      end
    end
  end
end