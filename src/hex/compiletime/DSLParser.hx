package hex.compiletime;

#if macro
import hex.compiletime.error.IExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.error.VirtualMethodException;
import hex.parser.AbstractContextParser;

/**
 * ...
 * @author Francis Bourre
 */
class DSLParser<ContentType, RequestType> extends AbstractContextParser<ContentType, RequestType>
{
	var _applicationContextName 	: String;
	var _applicationContextClass 	: {name: String, pos: haxe.macro.Expr.Position};
	var _importHelper 				: ClassImportHelper;
	var _exceptionReporter 			: IExceptionReporter<ContentType>;
	
	public function new() 
	{
		super();
	}
	
	override public function setContextData( data : ContentType ) : Void
	{
		if ( data != null )
		{
			this._contextData = data;
			this._applicationContextName = this._findApplicationContextName( data );
			this._applicationContextClass = this._findApplicationContextClass( data );
					
			var applicationContext = this._applicationAssembler.getApplicationContext( this._applicationContextName, this._applicationContextDefaultClass );
			this._builder = this._applicationAssembler.getFactory( this._factoryClass, applicationContext );
		}
		else
		{
			this._exceptionReporter.report( "Context data is null." );
		}
	}
	
	@final
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	@final
	public function setExceptionReporter( exceptionReporter : IExceptionReporter<ContentType> ) : Void
	{
		this._exceptionReporter = exceptionReporter;
	}
	
	function _findApplicationContextName( data : ContentType ) : String
	{
		throw new VirtualMethodException();
	}
	
	function _findApplicationContextClass( data : ContentType ) : {name: String, pos: haxe.macro.Expr.Position}
	{
		throw new VirtualMethodException();
	}
}
#end