package hex.compiletime.flow.parser;

/**
 * ...
 * @author Francis Bourre
 */
#if macro

import haxe.macro.*;

typedef ExpressionParser =
{
	var parseType 			: TypeParser;
	var parseArgument 		: ArgumentParser;
	var parseProperty 		: PropertyParser;
	var parseMapArgument 	: MapArgumentParser;
	var typeParser			: Map<String, ExpressionParser->ID->Array<Expr>->Expr->hex.vo.ConstructorVO>;
	var methodParser		: Map<String, ExpressionParser->ID->Array<Expr>->Expr->hex.vo.ConstructorVO>;
}

typedef ID 					= String;
typedef FieldName 			= String;
typedef TypeParser 			= ExpressionParser->ID->Expr->hex.vo.ConstructorVO;
typedef ArgumentParser 		= ExpressionParser->ID->Expr->hex.vo.ConstructorVO;
typedef MapArgumentParser 	= ExpressionParser->ID->Expr->hex.vo.MapVO;
typedef PropertyParser 		= ExpressionParser->ID->FieldName->Expr->hex.vo.PropertyVO;
#end