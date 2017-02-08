package hex.mock;

import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class ClassWithConstantConstantArgument
{
	public var constant : MessageType;
	
	public function new( constant : MessageType ) 
	{
		this.constant = constant;
	}
}