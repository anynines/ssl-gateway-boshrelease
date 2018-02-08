module CustomMatcher
  def expect_https_redirect(app_name, domain)
    response Net::HTTP.get_response(URI("http://#{app_name}.#{domain}"))
    expect(response == 301)
    expect(response.headers["location"] == URI("https://#{app_name}.#{domain}"))
  end

  def expect_request(app_name, domain, port, expected_response_code)
    if port == 80
      expect(HTTParty.get("http://#{app_name}.#{domain}:#{port}", :verify => false).code == expected_response_code)
    else
      expect(HTTParty.get("https://#{app_name}.#{domain}:#{port}", :verify => false).code == expected_response_code)
    end
  end

  def check_tcp_socket(app_name, domain, port)
    TCPSocket.new("#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}", 2222).close
  end

  def check_ssl_cert_bundle(instances, should_bundle, is_bundle)
    should = File.read(File.join(__dir__, should_bundle)).gsub("\n", "")
    instances.each { |instance| expect(BoshHelpers::scp_read(instance, is_bundle)).to eq(should) }
  end
end
