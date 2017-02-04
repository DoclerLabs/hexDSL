package hex.parser;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.error.VirtualMethodException;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractContextParser<ContentType> implements IContextParser<ContentType>
{
	var _applicationAssembler 			: IApplicationAssembler;
	var _contextData 					: ContentType;
	var _factoryClass 					: Class<IBuilder<Dynamic>>;
	var _applicationContextDefaultClass : Class<IApplicationContext>;

	function new() 
	{
		//
	}
	
	public function parse() : Void
	{
		throw new VirtualMethodException();
	}
	
	@final
	public function getContextData() : ContentType
	{
		return this._contextData;
	}

	public function setContextData( data : ContentType ) : Void
	{
		throw new VirtualMethodException();
	}
	
	@final
	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._applicationAssembler = applicationAssembler;
	}
	
	@final
	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._applicationAssembler;
	}
	
	@final
	public function setFactoryClass( factoryClass: Class<IBuilder<Dynamic>> ) : Void
	{
		this._factoryClass = factoryClass;
	}
	
	@final
	public function setApplicationContextDefaultClass( applicationContextDefaultClass : Class<IApplicationContext> ) : Void
	{
		this._applicationContextDefaultClass = applicationContextDefaultClass;
	}
}