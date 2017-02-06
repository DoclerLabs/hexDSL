package hex.compiletime;

#if macro
import haxe.macro.Context;
import hex.compiletime.error.IExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeParser<ContentType, RequestType, ParserType : DSLParser<ContentType, RequestType>> 
{
	var _contextData 		: ContentType;
	var _assembler 			: IApplicationAssembler;
	var _importHelper 		: ClassImportHelper;
	var _parserCollection 	: AbstractParserCollection<ParserType>;
	var _exceptionReporter 	: IExceptionReporter<ContentType>;
	
	public function new( parserCollection : AbstractParserCollection<ParserType> )
	{
		this._parserCollection = parserCollection;
	}
	
	public function setImportHelper( importHelper : ClassImportHelper ) : Void
	{
		this._importHelper = importHelper;
	}
	
	public function setExceptionReporter( exceptionReporter : IExceptionReporter<ContentType> ) : Void
	{
		this._exceptionReporter = exceptionReporter;
	}

	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._assembler = applicationAssembler;
	}

	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._assembler;
	}

	public function setContextData( contextData : ContentType ) : Void
	{
		this._contextData = contextData;
	}

	public function getContextData() : ContentType
	{
		return this._contextData;
	}

	public function parse( 	
							applicationAssembler 			: IApplicationAssembler, 
							contextData 					: ContentType, 
							factoryClass					: Class<IBuilder<RequestType>>,
							applicationContextDefaultClass 	: Class<IApplicationContext>
						) : Void
	{
		if ( this._exceptionReporter == null )
		{
			Context.error ( "Exception reporter is null", Context.currentPos() );
		}
		
		if ( applicationAssembler != null )
		{
			this.setApplicationAssembler( applicationAssembler );

		} else
		{
			this._exceptionReporter.report( "Application assembler is null" );
		}

		if ( contextData != null )
		{
			this.setContextData( contextData );

		} else
		{
			this._exceptionReporter.report( "Context data is null" );
		}
		
		if ( factoryClass == null )
		{
			this._exceptionReporter.report( "Factory class is null" );
		}
		
		if ( applicationContextDefaultClass == null )
		{
			this._exceptionReporter.report( "ApplicationContext default class is null" );
		}

		if ( this._parserCollection == null )
		{
			this._exceptionReporter.report( "Parsers collection is null" );
		}

		while ( this._parserCollection.hasNext() )
		{
			//Get current parser
			var parser = this._parserCollection.next();
			
			//Initialize settings
			parser.setFactoryClass( factoryClass );
			parser.setApplicationContextDefaultClass( applicationContextDefaultClass );
			parser.setImportHelper( this._importHelper );
			parser.setExceptionReporter( this._exceptionReporter );
			parser.setApplicationAssembler( this._assembler );
			
			//Do parsing
			parser.setContextData( this._contextData );
			parser.parse();

			//Get back parsed data
			this._contextData = parser.getContextData();
		}

		this._parserCollection.reset();
	}
}
#end