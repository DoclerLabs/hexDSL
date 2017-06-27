package hex.compiletime.flow.parser;

#if macro

/**
 * ...
 * @author Francis Bourre
 */
class RuntimeParameterParser extends AbstractExprParser<hex.compiletime.basic.BuildRequest>
{
	var _runtimeParam : hex.preprocess.RuntimeParam;
	
	public function new( runtimeParam : hex.preprocess.RuntimeParam ) 
	{
		super();
		this._runtimeParam 		= runtimeParam;
	}
	
	override public function parse() : Void
	{
		hex.preprocess.RuntimeParametersPreprocessor.getTypes( this._runtimeParam ).map(
			function ( param )
			{
				var vo = new hex.vo.PreProcessVO( param.name, [param.type] );
				vo.filePosition = param.pos;
				this._builder.build( PREPROCESS( vo ) );
			}
		);
	}
}
#end