package hex.compiletime.xml;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import hex.compiletime.DSLData;
import hex.compiletime.DSLPosition;

/**
 * ...
 * @author Francis Bourre
 */
class PositionTracker implements IXmlPositionTracker
{
	public var nodeMap( default, never ) 		: Map<Xml, DSLPosition> = new Map<Xml, DSLPosition>();
	public var attributeMap( default, never ) 	: Map<Xml, Map<String, DSLPosition>> = new Map<Xml, Map<String, DSLPosition>>();
	public var dslData 							: DSLData;
	
	public function new( dslData : DSLData ) 
	{
		this.dslData = dslData;
	}
	
	public function makePositionFromNode( xml : Xml ) : Position
	{
		var dslPosition = this.nodeMap.get( xml );

		return ( dslPosition == null ) ? 
			Context.makePosition( { min: 0, max: dslData.length, file: dslData.path } ):
			Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
	}
	
	public function makePositionFromAttribute( xml : Xml, attributeName : String ) : Position
	{
		#if ( haxe_ver < 4 )
		var dslPosition = this.attributeMap.get( xml ).get( attributeName );
		return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
		
		//TODO Ugly try/catch to be removed when Map 2macro time will be fixed.
		#else
		try
		{
			var dslPosition = this.attributeMap.get( xml ).get( attributeName );
			return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
		}
		catch ( e : Dynamic )
		{
			var dslPosition = this.nodeMap.get( xml );
			return Context.makePosition( { min: dslPosition.from, max: dslPosition.to, file: dslPosition.file } );
		}
		#end
	}
	
	public function getPosition( xml : Xml, ?attributeName : String ) : Position
	{
		return attributeName == null ? this.makePositionFromNode( xml ) : this.makePositionFromAttribute( xml, attributeName );
	}
}
#end