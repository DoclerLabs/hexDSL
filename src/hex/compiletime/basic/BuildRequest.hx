package hex.compiletime.basic;

import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

/**
 * @author Francis Bourre
 */
enum BuildRequest 
{
	OBJECT( vo : ConstructorVO );
	PROPERTY( vo : PropertyVO );
	METHOD_CALL( vo : MethodCallVO );
}