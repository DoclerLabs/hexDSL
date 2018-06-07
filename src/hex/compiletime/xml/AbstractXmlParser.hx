package hex.compiletime.xml;

#if macro
import hex.compiletime.DSLParser;
import hex.core.IApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractXmlParser<RequestType> extends DSLParser<Xml, RequestType>
{
	var _positionTracker : IXmlPositionTracker;
	
	function new() 
	{
		super();
	}
	
	@final
	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextDefaultClass );
	}
	
	@final
	override public function setContextData( data : Xml ) : Void
	{
		this._positionTracker = cast ( this._exceptionReporter, ExceptionReporter ).positionTracker;

		if ( Std.is( data, Xml ) )
		{
			super.setContextData( data );
		}
		else
		{
			this._exceptionReporter.report( "Context data should be an instance of Xml." );
		}
	}
	//TODO MAKE PACK
	override function _findApplicationContextName( xml : Xml ) : String
	{
		return xml.firstElement().get( ContextAttributeList.NAME );
		
		if ( this._applicationContextName == null )
		{
			this._exceptionReporter.report( "Fails to retrieve applicationContext name. You should add 'name' attribute to the root of your xml context", 
				this._positionTracker.getPosition( xml  ) );
		}
	}
	
	override function _findApplicationContextClass( xml : Xml ) : {name: String, pos: haxe.macro.Expr.Position}
	{
		var name = xml.firstElement().get( ContextAttributeList.TYPE );
		var pos = name != null ? this._positionTracker.getPosition( xml.firstElement() ) : null;

		return { name: name, pos: pos };
	}
	
	function _throwMissingTypeException( type : String, xml : Xml, attributeName : String ) : Void 
	{
		this._exceptionReporter.report( "Type not found '" + type + "' ", this._positionTracker.getPosition( xml, attributeName ) );
	}
}
#end