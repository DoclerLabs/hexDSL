package hex.compiletime.basic;

import hex.compiletime.basic.CompileTimeCoreFactory;
import hex.core.AbstractApplicationContext;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeApplicationContext extends AbstractApplicationContext
{
	@:allow( hex.compiletime )
	function new( applicationContextName : String )
	{
		super( new CompileTimeCoreFactory(), applicationContextName );
	}
}