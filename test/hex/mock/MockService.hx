package hex.mock;

/**
 * ...
 * @author Francis Bourre
 */
class MockService 
{
	public var gateway : String;
	
	public function new( gateway : String = '' ) 
	{
		this.gateway = gateway;
	}
	
	public function getGateway() : String
	{
		return this.gateway;
	}
	
	public function getGatewayURL( url: String, page: String ) return url + page;
	
	static public function clone( service: MockService, gatewayURL: String ) 
	{
		return new MockService( gatewayURL );
	}
}