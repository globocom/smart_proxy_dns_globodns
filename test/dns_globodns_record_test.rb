require 'test_helper'

require 'smart_proxy_dns_globodns/dns_globodns_main'

class DnsGloboDNSRecordTest < Test::Unit::TestCase
  # Test that a missing :example_setting throws an error
  def test_initialize_without_settings
    assert_raise(RuntimeError) do
      klass.new(settings.delete_if { |k,v| k == :auth_token || k == :host })
    end
  end

  # Test that correct initialization works
  def test_initialize_with_settings
    assert_nothing_raised do
      klass.new(settings)
    end
  end

  # Test A record creation
  def test_create_a
    record = klass.new(settings)
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)
    conn.expects(:new_record).with('test.example.com', 'A', '10.1.1.1')

    assert record.create
  end

  # Test A record creation fails if the record exists
  def test_create_a_conflict

    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:new_record).with('test.example.com', 'A', '10.1.1.1').raises( GlobodnsClient::AlreadyExists, "error")

    assert_raise(Proxy::Dns::Collision) { klass.new(settings).create }
  end

  # Test PTR record creation
  def test_create_ptr
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:new_record).with('10.1.1.1', 'PTR', 'test.example.com')


    assert klass.new(settings.merge(:type => 'PTR')).create
  end

  # Test PTR record creation fails if the record exists
  def test_create_ptr_conflict
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:new_record).with('10.1.1.1', 'PTR', 'test.example.com').raises( GlobodnsClient::AlreadyExists, "error")

    assert_raise(Proxy::Dns::Collision) { klass.new(settings.merge(:type => 'PTR')).create }
  end

  # Test A record removal
  def test_remove_a
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:delete_record).with('test.example.com', 'A')

    assert klass.new(settings).remove
  end

  # Test A record removal fails if the record doesn't exist
  def test_remove_a_not_found
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:delete_record).with('test.example.com', 'A').raises( GlobodnsClient::NotFound, "error")

    assert_raise(Proxy::Dns::NotFound) { assert klass.new(settings).remove }
  end

  # Test PTR record removal
  def test_remove_ptr
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:delete_record).with('10.1.1.1', 'PTR')

    assert klass.new(settings.merge(:type => 'PTR')).remove
  end

  # Test PTR record removal fails if the record doesn't exist
  def test_remove_ptr_not_found
    conn = mock()
    GlobodnsClient::Connection.expects(:new).with(auth_token: settings[:auth_token], host: settings[:host]).returns(conn)

    conn.expects(:delete_record).with('10.1.1.1', 'PTR').raises( GlobodnsClient::NotFound, "error")

    assert_raise(Proxy::Dns::NotFound) { assert klass.new(settings.merge(:type => 'PTR')).remove }
  end

  private

  def klass
    Proxy::Dns::GloboDNS::Record
  end

  def settings
    {
      :auth_token => 'foo',
      :host => 'globodns.com',
      :fqdn => 'test.example.com',
      :value => '10.1.1.1',
      :type => 'A'
    }
  end
end
