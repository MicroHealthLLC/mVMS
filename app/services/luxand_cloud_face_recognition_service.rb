require 'uri'
require 'net/http'
require 'openssl'

class LuxandCloudFaceRecognitionService

  def initialize
  end

  def recognize(image_url)
    begin
      url = URI("https://luxand-cloud-face-recognition.p.rapidapi.com/photo/search")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request["x-rapidapi-key"] = ENV['RAPID_API_KEY']
      request["x-rapidapi-host"] = 'luxand-cloud-face-recognition.p.rapidapi.com'
      request.body = "photo=#{image_url}"

      response = http.request(request)
      puts response.read_body
      JSON.parse(response.read_body)
    rescue StandardError => e
      puts e
    end
  end

  def create_person(name)
    url = URI("https://luxand-cloud-face-recognition.p.rapidapi.com/subject")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["x-rapidapi-key"] = ENV['RAPID_API_KEY']
    request["x-rapidapi-host"] = 'luxand-cloud-face-recognition.p.rapidapi.com'
    request.body = "name=#{name}"

    response = http.request(request)
    puts response.read_body
    JSON.parse(response.read_body)
  end

  def add_face_to_person(person_id, image_url)
    url = URI("https://luxand-cloud-face-recognition.p.rapidapi.com/subject/#{person_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["x-rapidapi-key"] = ENV['RAPID_API_KEY']
    request["x-rapidapi-host"] = 'luxand-cloud-face-recognition.p.rapidapi.com'
    request.body = "photo=#{image_url}"

    response = http.request(request)
    puts response.read_body
    JSON.parse(response.read_body)
  end
end
