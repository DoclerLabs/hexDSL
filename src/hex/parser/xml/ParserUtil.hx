package hex.parser.xml;

import hex.compiletime.xml.ContextAttributeList;
import hex.compiletime.xml.ContextNodeNameList;
import hex.core.ContextTypeList;
import hex.vo.ConstructorVO;
import hex.vo.MapVO;

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class ParserUtil
{
	function new() 
	{
		
	}

	public static function getArguments( ownerID : String, xml : Xml, type : String ) : Array<Dynamic>
	{
		var args : Array<Dynamic> 	= [];
		var iterator 				= xml.elementsNamed( ContextNodeNameList.ARGUMENT );

		if ( iterator.hasNext() )
		{
			while ( iterator.hasNext() )
			{
				args.push( ParserUtil._getConstructorVOFromXML( ownerID, iterator.next() ) );
			}
		}
		else
		{
			//TODO please remove that shit
			var value : String = xml.get( ContextAttributeList.VALUE );
			if ( value != null ) 
			{
				if 
				( 
					type == null ||
					type == ContextTypeList.STRING ||
					type == ContextTypeList.INT ||
					type == ContextTypeList.UINT || 
					type == ContextTypeList.FLOAT || 
					type == ContextTypeList.BOOLEAN || 
					type == ContextTypeList.NULL ||
					type == ContextTypeList.CLASS
				)
				{
					args = [ xml.get( ContextAttributeList.VALUE ) ];
				}
				else 
				{
					args.push( new ConstructorVO( ownerID, ContextTypeList.STRING, [ xml.get( ContextAttributeList.VALUE ) ] ) );
				}
			}
		}

		return args;
	}
	
	public static function _getConstructorVOFromXML( ownerID : String, item : Xml ) : ConstructorVO
	{
		var method 		= item.get( ContextAttributeList.METHOD );
		var ref 		= item.get( ContextAttributeList.REF );
		var staticRef 	= item.get( ContextAttributeList.STATIC_REF );
		var factory 	= item.get( ContextAttributeList.FACTORY_METHOD );
		
		if ( method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ method ] );

		} else if ( ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, item.get( ContextAttributeList.REF ) );

		} else if ( staticRef != null )
		{
			return new ConstructorVO( null, ContextTypeList.STATIC_VARIABLE, null, null, null, false, null, null, item.get( ContextAttributeList.STATIC_REF ) );

		} else
		{
			var type : String = item.get( ContextAttributeList.TYPE );
			
			if ( type == null )
			{
				type = ContextTypeList.STRING;
			}

			return new ConstructorVO( ownerID, type, [ item.get( ContextAttributeList.VALUE ) ] );
		}
	}
	
	public static function _getConstructorVO( ownerID : String, item : Dynamic ) : ConstructorVO
	{
		var type 		= item.type;
		var method 		= item.method;
		var ref 		= item.ref;
		var staticRef 	= item.staticRef;
		var value 		= item.value;
		var factory 	= item.factory;

		if ( method != null )
		{
			return new ConstructorVO( null, ContextTypeList.FUNCTION, [ method ] );

		} else if ( ref != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, ref );

		} else if ( staticRef != null )
		{
			return new ConstructorVO( null, ContextTypeList.INSTANCE, null, null, null, false, null, null, staticRef );

		} else
		{
			if ( type == null )
			{
				type = ContextTypeList.STRING;
			}

			return new ConstructorVO( ownerID, type, [ value ] );
		}
	}

	public static function getMethodCallArguments( ownerID : String, xml : Xml ) : Array<ConstructorVO>
	{
		var args : Array<ConstructorVO> = [];
		var iterator = xml.elementsNamed( ContextNodeNameList.ARGUMENT );

		while ( iterator.hasNext() )
		{
			args.push( _getConstructorVOFromXML( ownerID, iterator.next() ) );
		}
		
		return args;
	}
	
	public static function getMapArguments( ownerID : String, xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNodeNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			var keyList 	= item.elementsNamed( ContextNodeNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNodeNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				var key 	= ParserUtil._getAttributes( keyList.next() );
				var value 	= ParserUtil._getAttributes( valueList.next() );

				args.push( new MapVO( 	
										ParserUtil._getConstructorVO( ownerID, key ), 
										ParserUtil._getConstructorVO( ownerID, value ), 
										item.get( ContextAttributeList.MAP_NAME ),
										item.get( ContextAttributeList.AS_SINGLETON ) == "true",
										item.get( ContextAttributeList.INJECT_INTO ) == "true"
									) );
			}
		}

		return args;
	}

	public static function _getAttributes( xml : Xml ) : Dynamic
	{
		var obj : Dynamic = {};
		var iterator = xml.attributes();
		
		while ( iterator.hasNext() )
		{
			var attribute = iterator.next();
			Reflect.setField( obj, attribute, xml.get( attribute ) );
		}

		return obj;
	}
	
	static public function getMapType( xml : Xml ) : Array<String>
	{
		var s = xml.get( ContextAttributeList.MAP_TYPE );
		if ( s != null )
		{
			var a = s.split( ";" );
			return [ for ( e in a ) e.trim() ];
		}
		
		return null;
	}
}