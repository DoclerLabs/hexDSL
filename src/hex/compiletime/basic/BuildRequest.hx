package hex.compiletime.basic;

/**
 * @author Francis Bourre
 */
enum BuildRequest 
{
	PREPROCESS( vo : hex.vo.PreProcessVO );
	OBJECT( vo : hex.vo.ConstructorVO );
	PROPERTY( vo : hex.vo.PropertyVO );
	METHOD_CALL( vo : hex.vo.MethodCallVO );
}