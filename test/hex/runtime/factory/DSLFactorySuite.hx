package hex.runtime.factory;

/**
 * ...
 * @author Francis Bourre
 */
class DSLFactorySuite
{
	@Suite( "Factory" )
    public var list : Array<Class<Dynamic>> = [ArrayFactoryTest, BoolFactoryTest, ClassFactoryTest, FloatFactoryTest, IntFactoryTest, NullFactoryTest, StringFactoryTest, UIntFactoryTest];
}