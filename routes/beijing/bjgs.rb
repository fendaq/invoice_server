# http://www.bjtax.gov.cn/ptfp/getVFImage

# 假
# 111001172011
# 24918684
# 20375865

# 111001481002
# 38406103
# 57115454

# 110108683580875
# 北京今飞腾文化发展有限公司
# 1100153320
# 00769058
# 29.73
# 2015-09-17

# 北京国税

# 流程:
# get 请求验证码, 需要带一个 sessonrandom 和 sessionId, 写死即可
# get 发送验证请求, 带上相应参数, 如发票代码, 号码, 密码, 纳税人, 开票日期, 金额等. 还有 ip 和 lastSession 也是写死即可
require 'open-uri'
require 'mechanize'

class Bjgs < Cuba
  define do
    login_url   = 'http://www.bjtax.gov.cn/ptfp/fpindex.jsp'
    captcha_img = 'http://www.bjtax.gov.cn/ptfp/getVFImage?sessionrandom=0.22091103880666196&sessionId=WfYY6vMyYQ4qqwVWH9z1D91kKWLpL8LZMsfZ10NZr9npCp9LJyZw!-1812916159!1444894904713'
    verify_url  = 'http://www.bjtax.gov.cn/ptfp/turna.jsp'

    on 'captcha' do
      on get do
        agent = Mechanize.new
        agent.get (login_url) do |login|
          session[:ip] = login.form['ip']
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
    end

    on default do
      on get do
        render("bjgs", title: "北京国税")
      end

      on post, param("fpdm"), param("fphm"), param("fpmm"), param("yzm") do |fpdm, fphm, fpmm, yzm|
        agent = Mechanize.new

        result = agent.get(verify_url +
                           '?valiNum=' + yzm +
                           '&fpdm=' + fpdm +
                           '&fphm=' + fphm +
                           '&fpmm=' +
                           '&sfzh=' +
                           '&ip='   + '10.1.100.5' +
                           '&kpri=' + '2015-09-17' +
                           '&nsr='  + '110108683580875' +
                           '&isFrist=' + '1' +
                           '&kjje=' + 
                           '&lastSession=' + 'WfYY6vMyYQ4qqwVWH9z1D91kKWLpL8LZMsfZ10NZr9npCp9LJyZw!-1812916159!1444894904713'
                          )
        puts result.body   
      end
    end
  end
end