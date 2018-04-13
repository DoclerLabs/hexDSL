package hex.mock;

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

abstract MessageType( String )
{
	inline public function new( name : String ) this = name;
	@:from public static inline function fromString( s : String ) return new MessageType( s );
	@:to public inline function toString() return this;
}