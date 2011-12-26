#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
require 'test/unit'
require 'pp'

class TC_Metasploit < Test::Unit::TestCase

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  #
  # Test the api is functional
  #
  def test_requires
    assert_nothing_raised do
      require 'msfrpc-client'
    end
  end

  #
  # Load the config for testing
  #
  def load_config
    BeEF::Core::Configuration.instance.load_extensions_config
    @config = BeEF::Core::Configuration.instance.get('beef.extension.metasploit')
  end

  # Create an api instance
  def new_api
      load_config
      require 'extensions/metasploit/extension.rb'
      @api = BeEF::Extension::Metasploit::RpcClient.instance
  end
 
  #
  # Verify that the config file has required information
  # 
  def test_config
    load_config
    assert(@config.key?('user'))
    assert(@config.key?('pass'))
    assert(@config.key?('port'))
    assert(@config.key?('uri'))
    assert(@config.key?('callback_host'))
    assert(@config.key?('autopwn_url'))
  end

  #
  # Verify that we can create an API instance
  #
  def test_api_create
    assert_nothing_raised do
      new_api
    end
  end

  #
  # Verify that the login is working
  #
  def test_login
    new_api
    assert(@api.login)
  end

  def test_call
    new_api
    @api.login
    assert(@api.call('core.version'))
  end
  
  def test_browser_exploits
    new_api
    @api.login
    exploits = nil
    assert_nothing_raised do
    	exploits =  @api.browser_exploits()
    end
    assert(exploits.length > 5)
  end

  def test_exploit_info
    new_api
    @api.login
    info = nil
    assert_nothing_raised do
    	info = @api.get_exploit_info('windows/dcerpc/ms03_026_dcom')
    end
    assert( info['name'].nil? != true)
  end
  
  def test_get_options
    new_api
    @api.login
    info = nil
    assert_nothing_raised do
    	info = @api.get_options('windows/dcerpc/ms03_026_dcom')
    end
    assert( info['RHOST'].nil? != true)
  end

  def test_payloads
    new_api
    @api.login
    payloads = nil
    assert_nothing_raised do
    	payloads = @api.payloads
    end
    assert( payloads.length > 5 )
  end

  def test_launch_exploit
    new_api
    @api.login
    opts = { 'PAYLOAD' => 'windows/meterpreter/bind_tcp', 'URIPATH' => '/test1','SRVPORT' => 8080}
    ret = nil
    assert_nothing_raised do
    	ret = @api.launch_exploit('windows/browser/adobe_utilprintf',opts)
    end
    assert(ret['job_id'] != nil )
  end

  def test_launch_autopwn
    new_api
    @api.login
    ret = nil
    assert_nothing_raised do
    	ret = @api.launch_autopwn
    end
    assert(ret['job_id'] != nil )
  end
end