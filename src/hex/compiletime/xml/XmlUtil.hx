package hex.compiletime.xml;

/**
 * ...
 * @author Francis Bourre
 */
class XmlUtil 
{
	public function new() 
	{
		
	}
	
	static public function getIfList( xml : Xml ) : Array<String>
	{
		var s = xml.get( ContextAttributeList.IF );
		return s != null ? s.split( "," ) : null;
	}
	
	static public function getIfNotList( xml : Xml ) : Array<String>
	{
		var s = xml.get( ContextAttributeList.IF_NOT );
		return s != null ? s.split( "," ) : null;
	}
}