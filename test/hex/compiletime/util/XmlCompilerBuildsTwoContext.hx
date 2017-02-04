package hex.compiletime.util;

import hex.core.IApplicationAssembler;
import hex.ioc.assembler.ApplicationAssembler;
import hex.ioc.assembler.IApplicationAssembler;
import hex.runtime.ApplicationAssembler;

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
		
		/*var o = test();
		o.filename();
		o.id = this;
		o.filename();*/
	}
	
	function assembleContext1() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/simpleInstanceWithArguments.xml" );
	}

	function assembleContext2() : Void
	{
		//XmlCompiler.readXmlFileWithAssembler( this._applicationAssembler, "context/referenceAnotherContext.xml" );
	}
	
	/*macro static function test()
	{
		var id = ContextUtil.buildInstanceField( "id", "hex.compiler.parser.xml.XmlCompilerBuildsTwoContext" );
		
		var contextExecution = ContextUtil.buildContextExecution( "filename" );
		
		ContextUtil.appendContextExecution( contextExecution, macro @:mergeBlock @:position( contextExecution.body.pos )
		{
			trace( "FuCk" );
			trace( this.id );
		} );
		
		var testClass = ContextUtil.buildContextDefintion( "assemblerID", "contextName" );
		testClass.fields.push( id );
		testClass.fields.push( contextExecution.field );

		//
		return ContextUtil.instantiateContextDefinition( testClass );
	}*/
}