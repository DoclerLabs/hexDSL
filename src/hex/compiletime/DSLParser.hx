package hex.compiletime;

import hex.compiletime.error.IExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.parser.AbstractContextParser;

/**
 * ...
 * @author Francis Bourre
 */
class DSLParser<ContentType, RequestType> extends AbstractContextParser<ContentType, RequestType>
{
	var _importHelper 		: ClassImportHelper;
	var _exceptionReporter 	: IExceptionReporter<ContentType>;
	
	public function new() 
	{
		super();
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
}