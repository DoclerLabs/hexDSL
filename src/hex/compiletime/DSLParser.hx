package hex.compiletime;

import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.error.IExceptionReporter;
import hex.parser.AbstractContextParser;

/**
 * ...
 * @author Francis Bourre
 */
class DSLParser<ContentType> extends AbstractContextParser<ContentType>
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