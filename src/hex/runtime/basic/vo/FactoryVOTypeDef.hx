package hex.runtime.basic.vo;

import hex.runtime.basic.IRunTimeContextFactory;
import hex.vo.ConstructorVO;

/**
 * @author Francis Bourre
 */
typedef FactoryVOTypeDef =
{
	constructorVO 	: ConstructorVO, 
	contextFactory 	: IRunTimeContextFactory
}