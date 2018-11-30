package hex.core;

/**
 * @author Francis Bourre
 */
class DependencyChecker implements IDependencyChecker
{
    var _m      : Map<String, Map<String, DependencyVO>>    = new Map();
    var _pos    : Map<String, haxe.macro.Expr.Position>     = new Map();

    public function new(){}

    public function registerDependency( vo: hex.vo.ConstructorVO ) : Void
    {
        var ownerID = vo.ID;
        if ( !_m.exists( ownerID ) ) 
        {
            _m.set( ownerID, new Map() );
            _pos.set( ownerID, vo.filePosition );
        }

        var visited = new Map<String, Bool>();
        visited.set( ownerID, true );

        var dependencies: Map<String, DependencyVO> = _m.get( ownerID );
        var args = vo.arguments;

        if ( args != null )
        {
            for ( arg in args )
            {
                var argRef = arg.ref;
                if ( argRef != null ) 
                {
                    dependencies.set( argRef, {ID: argRef, pos: arg.filePosition} );
                    f( argRef, _m, _pos, ownerID, visited, [ownerID] );
                }
            }
        }
    }

    static function f( 
                        argID:      String, 
                        m:          Map<String, Map<String, DependencyVO>>, 
                        pos:        Map<String, haxe.macro.Expr.Position>, 
                        ownerID:    String, 
                        visited:    Map<String, Bool>, tree: Array<String> )
    {
        if ( m.exists( argID ) )
        {
            var dependencies = m.get( argID );

            if ( !visited.exists( argID ) && dependencies.exists( ownerID ) )
            {
                tree.push( argID );
                for ( e in tree ) haxe.macro.Context.warning( "Circular dependency caught on '" + e + "'", pos.get( e ) );
                haxe.macro.Context.error( "Circular dependency caught between '" + ownerID + "' and '" + tree[1] + "'", pos.get( ownerID ) );
            }
            else
            {
                visited.set( argID, true );
                tree.push( argID );
                var it = dependencies.keys();
                while ( it.hasNext() ) 
                {
                    var arg = dependencies.get( it.next() );
                    if ( !visited.exists( arg.ID ) )  f( arg.ID, m, pos, ownerID, visited, tree );
                }
            }
        }
    }
}

typedef DependencyVO =
{
    ID: String,
    pos: haxe.macro.Expr.Position
}