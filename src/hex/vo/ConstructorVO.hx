package hex.vo;

/**
 * ...
 * @author Francis Bourre
 */
class ConstructorVO extends AssemblerVO
{
	#if macro
	public var cType : haxe.macro.Expr.ComplexType;
	#end
	
	public var              ID              	: String;
	public var              type (default, set) : String;
	
	@:deprecated
	public var              className           : String;
	
	public var              arguments       	: Array<Dynamic>;
	public var              factory         	: String;
	public var              staticCall       	: String;
	public var              staticArgs       	: Array<Dynamic>;
	public var              injectInto      	: Bool;
	public var              ref             	: String;
	public var 				mapTypes			: Array<String>;
	public var 				staticRef			: String;
	public var 				instanceCall		: String;
	
	public var 				fqcn				: String;
	
	public var 				abstractType 		: String;
	public var 				lazy 				: Bool;
	public var 				isPublic 			= false;
	
	public var 				shouldAssign		= true;
		
	public function new(  	id 					: String,
							?type 				: String,
							?args 				: Array<Dynamic>,
							?factory 			: String,
							?staticCall 		: String,
							?injectInto 		: Bool = false,
							?ref 				: String,
							?mapTypes 			: Array<String>,
							?staticRef 			: String )
	{
		super();
		
		this.ID         		= id;
		this.type       		= type;
		this.arguments  		= args;
		this.factory    		= factory;
		this.staticCall  		= staticCall;
		this.injectInto 		= injectInto;
		this.ref 				= ref;
		this.mapTypes 			= mapTypes;
		this.staticRef 			= staticRef;
	}
	
	function set_type( t : String ) : String
	{
		this.type 		= t;
		this.className	= t != null ? t.split( '<' )[ 0 ] : null;
		return t;
	}

	public function toString() : String
	{
		return 	"("
				+ "id:"                 + ID            	+ ", "
				+ "type:"               + type 				+ ", "
				+ "className:"          + className         + ", "
				+ "fcqn:"          		+ fqcn         		+ ", "
				+ "arguments:[" 		+ arguments 		+ "], "
				+ "factory:"    		+ factory       	+ ", "
				+ "staticCall:"  		+ staticCall 		+ ", "
				+ "injectInto:"  		+ injectInto 		+ ", "
				+ "ref:"  				+ ref 				+ ", "
				+ "mapTypes:"  			+ mapTypes 			+ ", "
				+ "staticRef:"          + staticRef 		+ ", "
				+ "shouldAssign:"   	+ shouldAssign 		+ ")";
	}
}