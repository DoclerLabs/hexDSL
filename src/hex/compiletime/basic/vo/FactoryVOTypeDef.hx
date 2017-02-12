package hex.compiletime.basic.vo;

import hex.compiletime.basic.IContextFactory;
import hex.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
typedef FactoryVOTypeDef =
{
	constructorVO 	: ConstructorVO, 
	contextFactory 	: IContextFactory
}