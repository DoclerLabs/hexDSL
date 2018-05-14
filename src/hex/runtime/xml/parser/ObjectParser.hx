package hex.runtime.xml.parser;

import hex.compiletime.xml.ContextAttributeList;
import hex.compiletime.xml.ContextNodeNameList;
import hex.compiletime.xml.XmlUtil;
import hex.core.ContextTypeList;
import hex.parser.xml.ParserUtil;
import hex.runtime.error.ParsingException;
import hex.runtime.xml.AbstractXMLParser;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectParser extends AbstractXMLParser<hex.compiletime.basic.BuildRequest>
{
	public function new() 
	{
		super();
	}
	
	override public function parse() : Void
	{
		var iterator = this._contextData.firstElement().elements();
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next() );
		}
	}
	
	function _parseNode( xml : Xml ) : Void
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
				throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
			}
		}

		var type 				: String;
		var args 				: Array<Dynamic>;
		var factory 			: String;
		var staticCall 			: String;
		var injectInto			: Bool;
		var mapType				: Array<String>;
		var staticRef			: String;
		var ifList				: Array<String>;
		var ifNotList			: Array<String>;

		// Build object.
		if ( shouldConstruct )
		{
			type = xml.get( ContextAttributeList.TYPE );

			if ( type == ContextTypeList.XML )
			{
				factory = xml.get( ContextAttributeList.PARSER_CLASS );
				args = [ xml.firstElement().toString() ];
				
				var constructorVO 		= new ConstructorVO( identifier, type, args, factory );
				constructorVO.ifList 	= XmlUtil.getIfList( xml );
				constructorVO.ifNotList = XmlUtil.getIfNotList( xml );

				this._builder.build( OBJECT( constructorVO ) );
			}
			else
			{
				var strippedType 	= type != null ? type.split( '<' )[ 0 ] : type;
				args 				= ( strippedType == ContextTypeList.HASHMAP || type == ContextTypeList.MAPPING_CONFIG ) ? ParserUtil.getMapArguments( identifier, xml ) : ParserUtil.getArguments( identifier, xml, type );
				factory 			= xml.get( ContextAttributeList.FACTORY_METHOD );
				staticCall 			= xml.get( ContextAttributeList.STATIC_CALL );
				injectInto			= xml.get( ContextAttributeList.INJECT_INTO ) == "true";
				mapType 			= ParserUtil.getMapType( xml );
				staticRef 			= xml.get( ContextAttributeList.STATIC_REF );

				if ( type == null )
				{
					type = staticRef != null ? ContextTypeList.STATIC_VARIABLE : ContextTypeList.STRING;
				}
				
				var constructorVO 		= new ConstructorVO( identifier, type, args, factory, staticCall, injectInto, null, mapType, staticRef );
				constructorVO.ifList 	= XmlUtil.getIfList( xml );
				constructorVO.ifNotList = XmlUtil.getIfNotList( xml );

				this._builder.build( OBJECT( constructorVO ) );
			}
		}
		

		// Build property.
		var propertyIterator = xml.elementsNamed( ContextNodeNameList.PROPERTY );
		while ( propertyIterator.hasNext() )
		{
			var property = propertyIterator.next();
			var propertyVO = new PropertyVO( 	identifier, 
												property.get( ContextAttributeList.NAME ),
												property.get( ContextAttributeList.VALUE ),
												property.get( ContextAttributeList.TYPE ),
												property.get( ContextAttributeList.REF ),
												property.get( ContextAttributeList.METHOD ),
												property.get( ContextAttributeList.STATIC_REF ) );
			
			propertyVO.ifList = XmlUtil.getIfList( xml );
			propertyVO.ifNotList = XmlUtil.getIfNotList( xml );
			
			this._builder.build( PROPERTY( propertyVO ) );
		}

		// Build method call.
		var methodCallIterator = xml.elementsNamed( ContextNodeNameList.METHOD_CALL );
		while( methodCallIterator.hasNext() )
		{
			var methodCallItem 		= methodCallIterator.next();
			var methodCallVO 		= new MethodCallVO( identifier, methodCallItem.get( ContextAttributeList.NAME ), ParserUtil.getMethodCallArguments( identifier, methodCallItem ) );
			methodCallVO.ifList 	= XmlUtil.getIfList( methodCallItem );
			methodCallVO.ifNotList 	= XmlUtil.getIfNotList( methodCallItem );
			
			this._builder.build( METHOD_CALL( methodCallVO ) );
		}
	}
}