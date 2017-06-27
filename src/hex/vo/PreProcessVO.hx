package hex.vo;

/**
 * ...
 * @author Francis Bourre
 */
class PreProcessVO extends AssemblerVO
{
	public var              ID              	: String;
	public var              arguments       	: Array<Dynamic>;
		
	public function new(  	id 					: String,
							?args 				: Array<Dynamic> )
	{
		super();
		
		this.ID         		= id;
		this.arguments  		= args;
	}

	public function toString() : String
	{
		return 	"("
				+ "id:"                 + ID            	+ ", "
				+ "arguments:[" 		+ arguments 		+ "]"
				+ ")";
	}
}