package hex.runtime.error;

import haxe.PosInfos;
using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
class ParsingException extends Error
{
    public function new ( message : String, ?posInfos : PosInfos ) super( code, message, pos );
}
