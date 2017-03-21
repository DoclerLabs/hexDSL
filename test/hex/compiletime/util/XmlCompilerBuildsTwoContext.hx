package hex.compiletime.util;

import hex.core.IApplicationAssembler;
import hex.runtime.ApplicationAssembler;
import hex.util.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompilerBuildsTwoContext 
{
	var _applicationAssembler : IApplicationAssembler;
	
	public function new() 
	{
		
	}
	
	@Test( "test building String with assembler" )
	public function testBuildingStringWithAssembler() : Void
	{
		this._applicationAssembler = new ApplicationAssembler();
		
		assembleContext1();
		assembleContext2();
		
		var o = getContext( "contextName", "applicationContextFilename" );
		o.applicationContextFilename();
		trace( Stringifier.stringify( o.id ) );
	}
	
	function assembleContext1() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/simpleInstanceWithArguments.xml" );
	}

	function assembleContext2() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/referenceAnotherContext.xml" );
	}
	
	macro static function getContext( applicationContextName : String, fileName : String )
	{
		var id = ContextUtil.buildInstanceField( "id", "hex.compiletime.util.XmlCompilerBuildsTwoContext" );
		
		var contextBuildingExecution = ContextUtil.buildContextExecution( fileName );
		
		ContextUtil.appendContextExecution( contextBuildingExecution, macro @:mergeBlock @:position( contextBuildingExecution.body.pos )
		{
			this.id = new XmlCompilerBuildsTwoContext();
		} );
		
		var contextClass = ContextUtil.buildContextDefintion( "assemblerID", applicationContextName );
		contextClass.fields.push( id );
		contextClass.fields.push( contextBuildingExecution.field );

		//
		return ContextUtil.instantiateContextDefinition( contextClass );
	}
}