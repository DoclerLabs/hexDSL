package hex.runtime.xml;

import hex.core.IApplicationAssembler;
import hex.parser.xml.ParserUtil;
import hex.util.MacroUtil;

#if macro
import haxe.macro.Context;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.compiletime.xml.ContextAttributeList;
import hex.compiletime.xml.ContextNodeNameList;
import hex.compiletime.util.ClassImportHelper;
import hex.preprocess.ConditionalVariablesChecker;
import hex.core.ContextTypeList;
import haxe.macro.Expr;
import hex.compiletime.xml.IXmlPositionTracker;
import hex.compiletime.xml.PositionTracker;
import hex.compiletime.xml.DSLReader;

using StringTools;
#end

/**
 * ...
 * @author Francis Bourre
 */
class BasicXmlReader
{
	#if macro
	static var _importHelper : ClassImportHelper;
	
	static function _parseNode( xml : Xml, positionTracker : IXmlPositionTracker ) : Void
	{
		var shouldConstruct = true;
	
		var identifier : String = xml.get( ContextAttributeList.ID );
		if ( identifier == null )
		{
			identifier = xml.get( ContextAttributeList.REF );
			if ( identifier != null )
			{
				shouldConstruct = false;
			}
			else
			{
				Context.error( "BasicXmlReader parsing error with '" + xml.nodeName + "' node, 'id' attribute not found.", positionTracker.makePositionFromNode( xml ) );
			}
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var mapType		: String;
		var staticRef	: String;

		// Build object.
		type = xml.get( ContextAttributeList.TYPE );

		if ( type == ContextTypeList.XML )
		{
			BasicXmlReader._importHelper.forceCompilation( xml.get( ContextAttributeList.PARSER_CLASS ) );
		}
		else
		{
			var strippedType = type != null ? type.split( '<' )[ 0 ] : type;
			if ( strippedType == ContextTypeList.HASHMAP || strippedType == ContextTypeList.MAPPING_CONFIG )
			{
				args = ParserUtil.getMapArguments( identifier, xml );
				for ( arg in args )
				{
					if ( arg.getPropertyKey() != null )
					{
						if ( arg.getPropertyKey().type == ContextTypeList.CLASS )
						{
							BasicXmlReader._importHelper.forceCompilation( arg.getPropertyKey().arguments[0] );
						}
					}
					
					if ( arg.getPropertyValue() != null )
					{
						if ( arg.getPropertyValue().type == ContextTypeList.CLASS )
						{
							BasicXmlReader._importHelper.forceCompilation( arg.getPropertyValue().arguments[0] );
						}
					}
				}
			}
			else
			{
				args = ParserUtil.getArguments( identifier, xml, type );
				for ( arg in args )
				{
					if ( !BasicXmlReader._importHelper.includeStaticRef( arg.staticRef ) )
					{
						BasicXmlReader._importHelper.includeClass( arg );
					}
				}
			}

			try
			{
				BasicXmlReader._importHelper.forceCompilation( type );
			}
			catch ( e : String )
			{
				Context.error( "BasicXmlReader parsing error with '" + xml.nodeName + "' node, '" + type + "' type not found.", positionTracker.makePositionFromAttribute( xml, ContextAttributeList.TYPE ) );
			}
			
			//map-type
			var mapTypes = ParserUtil.getMapType( xml );
			if ( mapTypes != null )
			{
				for ( mapType in mapTypes )
				{
					BasicXmlReader._importHelper.forceCompilation( mapType.split( '<' )[ 0 ] );
				}
			}
	
			if ( xml.get( ContextAttributeList.FACTORY_METHOD ) == null ) 
			{
				BasicXmlReader._importHelper.includeStaticRef( xml.get( ContextAttributeList.STATIC_REF ) );
			}
			
			if ( type == ContextTypeList.CLASS )
			{
				BasicXmlReader._importHelper.forceCompilation( args[ 0 ] );
			}

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNodeNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				BasicXmlReader._importHelper.includeStaticRef( propertyIterator.next().get( ContextAttributeList.STATIC_REF ) );
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNodeNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();

				args = ParserUtil.getMethodCallArguments( identifier, methodCallItem );
				for ( arg in args )
				{
					if ( !BasicXmlReader._importHelper.includeStaticRef( arg.staticRef ) )
					{
						BasicXmlReader._importHelper.includeClass( arg );
					}
					else if ( arg.type == ContextTypeList.CLASS )
					{
						BasicXmlReader._importHelper.forceCompilation( arg.value );
					}
					else if( arg.staticRef != null )
					{
						BasicXmlReader._importHelper.includeStaticRef( arg.staticRef );
					}
				}
			}
		}
	}
	
	public static function _readFile( 	fileName : String,
										?applicationContextName : String,
										?preprocessingVariables : Expr,
										?conditionalVariables : Expr ) : ExprOf<String>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		var data 						= document.toString();
		
		BasicXmlReader._importHelper 		= new ClassImportHelper();
		
		//DSL parsing
		var iterator = document.firstElement().elements();
		while ( iterator.hasNext() )
		{
			BasicXmlReader._parseNode( iterator.next(), reader.positionTracker );
		}
		
		return macro $v{ data };
	}
	#end
	
	macro public static function getXmlFileContent( fileName : String,
													?applicationContextName : String,
													?preprocessingVariables : Expr,
													?conditionalVariables : Expr ) : ExprOf<String>
	{
		return BasicXmlReader._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function getXml( fileName : String,
										 ?applicationContextName : String,
										 ?preprocessingVariables : Expr,
										 ?conditionalVariables : Expr ) : ExprOf<Xml>
	{
		var tp = MacroUtil.getPack( Type.getClassName( Xml ) );
		var data = BasicXmlReader._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
		return macro @:pos( Context.currentPos() ){ $p { tp }.parse( $data ); }
	}
	
	macro public static function read( 	fileName : String, 
										?applicationContextName : String,
										?preprocessingVariables : Expr, 
										?conditionalVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		var xmlPack = MacroUtil.getPack( Type.getClassName( Xml ) );
		var applicationAssemblerTypePath = MacroUtil.getTypePath( "hex.runtime.ApplicationAssembler" );
		var applicationXMLParserTypePath = MacroUtil.getTypePath( Type.getClassName( ApplicationParser ) );
		var data = BasicXmlReader._readFile( fileName, applicationContextName, preprocessingVariables, conditionalVariables );
		
		return macro @:pos( Context.currentPos() )
		{ 
			var applicationAssembler = new $applicationAssemblerTypePath(); 
			var applicationXmlParser = new $applicationXMLParserTypePath();
			applicationXmlParser.parse( applicationAssembler, $p { xmlPack }.parse( $data ) );
			applicationAssembler; 
		}
	}
}