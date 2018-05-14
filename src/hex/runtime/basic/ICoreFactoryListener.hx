package hex.runtime.basic;

/**
 * @author Francis Bourre
 */
typedef ICoreFactoryListener =
{
	function onRegister( key : String, value : Dynamic ) : Void;
    function onUnregister( key : String ) : Void;
}