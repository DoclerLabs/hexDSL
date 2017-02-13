package hex.compiletime.xml;

#if macro
import hex.compiletime.error.IExceptionReporter;

/**
 * ...
 * @author Francis Bourre
 */
class ExceptionReporter implements IExceptionReporter<Xml>
{
	public var positionTracker( default, null ) : IXmlPositionTracker;

	public function new( positionTracker : IXmlPositionTracker ) 
	{
		this.positionTracker = positionTracker;
	}
	
	public function report( message : String, ?position : haxe.macro.Expr.Position ) : Void
	{
		haxe.macro.Context.error( message, position != null ? position : haxe.macro.Context.currentPos() );
	}
}
#end