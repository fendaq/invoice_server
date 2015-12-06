# 北京地税
require 'open-uri'
require 'mechanize'
require 'stringio'
require 'base64'

# 流程:
#
# 1. 生成随机数, 请求验证码 image.jsp?ran=随机数 返回 jpeg 格式验证码图片
# 2. POST 查询地址
# "order": "on"
# "fpdmnumber": "211001573410"
# "fphmnumber": "02096161"
# "fppassword": "30744135"
# "rand":       验证码结果

# 返回结果 <table cellspacing="0" cellpadding="0" border="0"> 即结果

# 发票代码： 211001260140 
# 发票号码： 00388766 
# 密    码： 62171589 
# 购票单位：北京市朝阳区人民政府建外街道办事处
# 此发票不是第一次查询！ 
class Bjds < Cuba
  define do
    page_url = 'http://zwcx.tax861.gov.cn/fpcx.jsp'
    verify_url = 'http://zwcx.tax861.gov.cn/fpcxjg.jsp'
    captcha_url = 'http://zwcx.tax861.gov.cn/image.jsp'

    on 'captcha' do
      on get do
        agent = Mechanize.new
        agent.get(captcha_url + '?ran=' + rand().to_s) do |captcha|
          if captcha.code == '200'

            # 保存 Session 信息
            session[:cookies] = []
            agent.cookies.each {|c| session[:cookies] << c }
 
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
        render("bjds", title: "北京地税")
      end

      on post, param("fpdmnumber"), param("fphmnumber"), param("fppassword"), param("rand") do |fpdmnumber, fphmnumber, fppassword, rand|
        agent = Mechanize.new
        
        # 恢复 session 信息
        session[:cookies].each {|c| agent.cookie_jar.add! c}
        
        data = {
          "order"      => "on",
          "fpdmnumber" => fpdmnumber, 
          "fphmnumber" => fphmnumber,
          "fppassword" => fppassword,
          "rand"       => rand
        }

        result_page = agent.post(verify_url, data).body.encode("UTF-8", "GBK")
        # pp result_page
        result = Nokogiri::HTML.parse(result_page).css("td.bg")
        render("result", title: "验证结果", content: result)
      end
    end
  end

  private
  def save_session(some_str)
    @jsessionid = some_str
  end
end




# order:on
# fpdmnumber:211001260140
# fphmnumber:00388766
# fppassword:62171589
# rand:3

