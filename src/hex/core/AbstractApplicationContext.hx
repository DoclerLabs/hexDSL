package hex.core;

import hex.core.IApplicationContext;
import hex.core.ICoreFactory;
import hex.di.IDependencyInjector;
import hex.domain.Domain;
import hex.error.VirtualMethodException;
import hex.event.MessageType;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractApplicationContext implements IApplicationContext
{
	var _name 					: String;
	var _coreFactory 			: ICoreFactory;
	var _domain 				: Domain;
	
	public var test = 'test';
	
	public function new( coreFactory : ICoreFactory, name : String ) 
	{
		this._coreFactory	= coreFactory;
		this._name			= name;
		this._domain		= Domain.getDomain( name );
	}
	
	public function getName() : String
	{
		return this._name;
	}
	
	public function getDomain() : Domain
	{
		return this._domain;
	}

	public function dispatch( messageType : MessageType, ?data : Array<Dynamic> ) : Void
	{
		throw new VirtualMethodException();
	}
	
	public function getCoreFactory() : ICoreFactory 
	{
		return this._coreFactory;
	}
	
	public function getInjector() : IDependencyInjector 
	{
		return this._coreFactory.getInjector();
	}
	
	public function dispose() : Void
	{
		throw new VirtualMethodException();
	}
}