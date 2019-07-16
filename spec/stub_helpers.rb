module StubHelpers
  # consul service hosts query
  # 默认未service name为：service_name
  def stub_consul_service_query(expect_results)
    stub_request(:get, 'http://localhost:8500/v1/catalog/service/service_name').
      to_return(status: 200, body: expect_results.to_json, headers: {})
  end
end
