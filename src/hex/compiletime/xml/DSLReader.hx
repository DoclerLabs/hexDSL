package hex.compiletime.xml;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hex.compiletime.DSLData;
import hex.compiletime.xml.PositionTracker;
import hex.compiletime.xml.XmlParser;
import hex.compiletime.xml.XmlUtil;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.core.ContextAttributeList;
import hex.preprocess.MacroPreprocessor;

/**
 * ...
 * @author Francis Bourre
 */
class DSLReader
{
	public var positionTracker( default, null ) : PositionTracker;
	
	public function new(){}
	
	public function read( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : Xml
	{
		var xml = Xml.parse( '<root/>' );
		this._processFile( xml, fileName, true, preprocessingVariables, conditionalVariablesChecker );
		return xml;
	}
	
	function _processFile( finalXML: Xml, fileName: String, isRoot : Bool, ?preprocessingVariables: Expr, ?conditionalVariablesChecker: ConditionalVariablesChecker )
	{
		var finalRootXML = finalXML.firstElement();
	
		//read file
		var dsl = this._readFile( fileName );
		if ( this.positionTracker == null )
		{
			this.positionTracker = new PositionTracker( dsl );
		}
		
		//preprocess
		dsl.data = MacroPreprocessor.parse( dsl.data, preprocessingVariables );
		
		//xml building
		var rootXml = XmlParser.parse( dsl.data, dsl.path, this.positionTracker ).firstElement();
		
		if ( isRoot )
		{
			for ( att in rootXml.attributes() ) 
			{
				finalRootXML.set( att, rootXml.get( att ) );
			}
		}
		
		//collect include nodes
		var includeList : Array<Xml> = this._getIncludeList( rootXml, conditionalVariablesChecker );
		
		//parse/remove comditionals
		var iterator = rootXml.elements();
		while ( iterator.hasNext() )
		{
			var node : Xml = iterator.next();
			if ( this._isIncludeAllowed( node, conditionalVariablesChecker ) )
			{
				finalRootXML.addChild( node );
			}
		}
		
		//parse include collection
		for ( include in includeList )
		{
			var fileName = include.get( ContextAttributeList.FILE );
			this._processFile( finalXML, fileName, false, preprocessingVariables, conditionalVariablesChecker );
		}
	}
	
	function _getIncludeList( root : Xml, ?conditionalVariablesChecker: ConditionalVariablesChecker ) : Array<Xml>
	{
		var includeList : Array<Xml> = [];
		var includes = root.elementsNamed( "include" );
		while ( includes.hasNext() )
		{
			var node : Xml = includes.next();
			if ( this._isIncludeAllowed( node, conditionalVariablesChecker ) )
			{
				includeList.push( node );
			}

			root.removeChild( node );
		}

		return includeList;
	}
	
	function _isIncludeAllowed( node : Xml, ?conditionalVariablesChecker : ConditionalVariablesChecker ) : Bool
	{
		if ( conditionalVariablesChecker != null )
		{
			var ifList 				= XmlUtil.getIfList( node );
			var ifNotList 			= XmlUtil.getIfNotList( node );

			if ( conditionalVariablesChecker.allowsIfList( ifList ) && conditionalVariablesChecker.allowsIfNotList( ifNotList ) )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else 
		{
			return true;
		}
	}
	
	function _readFile( fileName : String, ?preprocessingVariables : Expr ) : DSLData
	{
		try
		{
			//resolve
			var path = Context.resolvePath( fileName );
			Context.registerModuleDependency( Context.getLocalModule(), path );
			
			//read data
			var data = sys.io.File.getContent( path );
			
			//instantiate result
			var result = 	{ 	
								data: 				data,
								length: 			data.length, 
								path: 				path,
							};
			
			return result;
		}
		catch ( error : Dynamic )
		{
			return Context.error( 'File loading failed @$fileName $error', Context.currentPos() );
		}
	}
}
#end