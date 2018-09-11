package hex.compiletime.flow;

import hex.compiletime.flow.BasicStaticFlowCompiler;
import hex.core.IApplicationAssembler;
import hex.runtime.ApplicationAssembler;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class BasicStaticFlowCompilerTest 
{
	var _myApplicationAssembler : IApplicationAssembler;
	static var applicationAssembler : IApplicationAssembler;

	@Before
	public function setUp() : Void
	{
		this._myApplicationAssembler = new ApplicationAssembler();
	}
	
	@After
	public function tearDown() : Void
	{
		this._myApplicationAssembler.release();
	}

	@Test( "test alias instance" )
	public function testAliasInstance() : Void
	{
		var code = BasicStaticFlowCompiler.compile( this._myApplicationAssembler, "context/flow/aliasInstance.flow", "BasicStaticFlowCompiler_aliasInstance" );
		code.execute();

		var position = code.locator.reference;
		Assert.equals( 1, position.x );
		Assert.equals( 2, position.y );
	}
}