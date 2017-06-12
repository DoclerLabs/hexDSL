package hex.compiletime.flow.parser;

/**
 * ...
 * @author Francis Bourre
 */
#if macro

import haxe.macro.*;
import hex.vo.ConstructorVO;

typedef ExpressionParser =
{
	var parseType 			: TypeParser;
	var parseArgument 		: ArgumentParser;
	var parseProperty 		: PropertyParser;
	var parseMapArgument 	: MapArgumentParser;
	var typeParser			: Map<String, ExpressionParser->ConstructorVO->Array<Expr>->Expr->ConstructorVO>;
	var methodParser		: Map<String, ExpressionParser->ConstructorVO->Array<Expr>->Expr->ConstructorVO>;
}

typedef ID 					= String;
typedef FieldName 			= String;
typedef TypeParser 			= ExpressionParser->ConstructorVO->Expr->ConstructorVO;
typedef ArgumentParser 		= ExpressionParser->ID->Expr->ConstructorVO;
typedef MapArgumentParser 	= ExpressionParser->ID->Expr->hex.vo.MapVO;
typedef PropertyParser 		= ExpressionParser->ID->FieldName->Expr->hex.vo.PropertyVO;
#end