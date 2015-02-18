class ApplicationController < ActionController::Base
  def getESStats
    @ES_SERVER="http://ec2-23-22-8-207.compute-1.amazonaws.com:9200/_nodes/stats"
    @API="/_nodes/stats"


    #Get stats

    url = URI.parse(ES_SERVER)

    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    Rails.logger.info res.body
    @stats = res.body
  end

end
