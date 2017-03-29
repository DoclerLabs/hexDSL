package hex.parser;

import hex.core.IApplicationAssembler;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.error.VirtualMethodException;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractContextParser<ContentType, RequestType> implements IContextParser<ContentType, RequestType>
{
	var _applicationAssembler 			: IApplicationAssembler;
	var _contextData 					: ContentType;
	var _factoryClass 					: Class<IBuilder<RequestType>>;
	var _applicationContextDefaultClass : Class<IApplicationContext>;
	var _builder 						: IBuilder<RequestType>;

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
	public function setFactoryClass( factoryClass: Class<IBuilder<RequestType>> ) : Void
	{
		this._factoryClass = factoryClass;
	}
	
	@final
	public function setApplicationContextDefaultClass( applicationContextDefaultClass : Class<IApplicationContext> ) : Void
	{
		this._applicationContextDefaultClass = applicationContextDefaultClass;
	}
	
	public function setApplicationContextName( name : String, locked : Bool = false ) : Void
	{
		throw new VirtualMethodException();
	}
}