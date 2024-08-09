/*
	File: Unary Operators
*/
/*
	Class: unary
	Represents a unary operator in the AST. Unary operators take a single operand (referred to as x below) and return a value.
*/
/node/expression/c_operator/unary
	precedence=OOP_UNARY

/*
	Class: LogicalNot
	Returns !x.

	Example:
	!true = false and !false = true
*/
//
/node/expression/c_operator/unary/LogicalNot
	name="logical not"

/*
	Class: BitwiseNot
	Returns the value of a bitwise not operation performed on x.

	Example:
	~10 (decimal 2) = 01 (decimal 1).
*/
//
/node/expression/c_operator/unary/BitwiseNot
	name="bitwise not"

/*
	Class: Minus
	Returns -x.
*/
//
/node/expression/c_operator/unary/Minus
	name="minus"

/*
	Class: group
	A special unary operator representing a value in parentheses.
*/
//
/node/expression/c_operator/unary/group
	precedence=OOP_GROUP

/node/expression/c_operator/unary/New(node/expression/exp)
		src.exp=exp
		return ..()
