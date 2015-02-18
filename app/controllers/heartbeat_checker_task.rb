require 'mail'

class HeartbeatCheckerTask
  def self.check
    puts "Executing the heartbeat checker"
    #@ES_HOST="192.168.1.143:9200"
    @ES_HOST="ec2-23-22-8-207.compute-1.amazonaws.com:9200"

    #Stats threshold for alarm
    product_search_max_milis = 10000

    client = Elasticsearch::Client.new host: @ES_HOST

    #Products
    #Test 1
    productsv2HeartBeatCheck = client.search index: 'products_v2', type: 'product', routing: '1',
                                             body: {
                                                 query:{
                                                     filtered: { query: { match_all: {}},
                                                                 filter: { term: { brand_id: '1'}}}
                                                 }
                                             }

    Rails.logger.info productsv2HeartBeatCheck
    product_QueryTime1 = productsv2HeartBeatCheck['took']
    product_timedout1 = productsv2HeartBeatCheck['timed_out']


    #Test 2 : TODO: Different query
    productsv2HeartBeatCheck = client.search index: 'products_v2', type: 'product', routing: '1',
                                             body: {
                                                 query:{
                                                     filtered: { query: { match_all: {}},
                                                                 filter: { term: { brand_id: '1'}}}
                                                 }
                                             }

    Rails.logger.info productsv2HeartBeatCheck
    product_QueryTime2 = productsv2HeartBeatCheck['took']
    product_timedout2 = productsv2HeartBeatCheck['timed_out']

    #Test 3
    productsv2HeartBeatCheck = client.search index: 'products_v2', type: 'product', routing: '1',
                                             body: {
                                                 query:{
                                                     filtered: { query: { match_all: {}},
                                                                 filter: { term: { brand_id: '1'}}}
                                                 }
                                             }
    Rails.logger.info productsv2HeartBeatCheck
    product_QueryTime3 = productsv2HeartBeatCheck['took']
    product_timedout3 = productsv2HeartBeatCheck['timed_out']

    @product_avgQueryTime = (product_QueryTime1 + product_QueryTime2 + product_QueryTime3)/3

    Rails.logger.info "#{@product_avgQueryTime}, #{@product_timedout} "
    if @product_avgQueryTime > product_search_max_milis           #or @product_timedout == 'true'
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
