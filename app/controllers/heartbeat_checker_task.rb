require 'mail'
require 'whenever'

class HeartbeatCheckerTask
  def check
    #@ES_HOST="192.168.1.143:9200"
    @ES_HOST="ec2-23-22-8-207.compute-1.amazonaws.com:9200"

    #Stats threshold for alarm
    product_search_max_milis = 6000

    client = Elasticsearch::Client.new host: @ES_HOST

    #Products
    productsv2HeartBeatCheck = client.search index: 'products_v2', type: 'product', routing: '1',
                                             body: {
                                                 query:{
                                                     filtered: { query: { match_all: {}},
                                                                 filter: { term: { brand_id: '1'}}}
                                                 }
                                             }

    Rails.logger.info productsv2HeartBeatCheck

    @product_avgQueryTime = productsv2HeartBeatCheck['took']
    @product_timedout = productsv2HeartBeatCheck['timed_out']

    Rails.logger.info "#{@product_avgQueryTime}, #{@product_timedout} "

    if @product_avgQueryTime > product_search_max_milis or @product_timedout == 'true' or @product_successful
      raiseAlarm("Search on products_v2 index timed out ")
    else
      @alarm = ''
    end

    #Instagram


  end
end

def raiseAlarm(msg)
  @alarm = "ALARM:: #{msg}"
  Rails.logger.error @alarm

  Mail.defaults do
    delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                             :port      => 587,
                             :domain    => "varunkr.com",
                             :user_name => "lazywiz",
                             :password  => "27619v85",
                             :authentication => 'plain',
                             :enable_starttls_auto => true }
  end

  mail = Mail.deliver do
    to 'elasticsearchalarm@readypulse.pagerduty.com'
    from 'Varun <varun@varunkr.com>'
    subject "Elasticsearch in alarm"
    text_part do
      body @alarm
    end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body "#{@alarm} \n\nindex: 'products_v2', type: 'product', routing: '1',
                                        body: {
                                             query:{
                                                 filtered: { query: { match_all: {}},
                                                             filter: { term: { brand_id: '1'}}}
                                             }
                                         }"
    end
  end
  Rails.logger.info "Alarm mail sent to PageDuty!"
end
