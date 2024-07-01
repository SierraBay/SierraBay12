/*
File: Options
*/
  //Ascii values of characters
var/global/const/ascii_A  = 65
var/global/const/ascii_Z  = 90
var/global/const/ascii_a  = 97
var/global/const/ascii_z  = 122
var/global/const/ascii_DOLLAR = 36
var/global/const/ascii_ZERO = 48
var/global/const/ascii_THALER = 254
var/global/const/ascii_NINE = 57
var/global/const/ascii_UNDERSCORE = 95

/*
	Class: n_scriptOptions
*/
/n_scriptOptions/proc/CanStartID(char) //returns true if the character can start a variable, function, or keyword name (by default letters or an underscore)
	if(!isnum(char))char=text2ascii(char)
	return (char in ascii_A to ascii_Z) || (char in ascii_a to ascii_z) || char==ascii_UNDERSCORE || char==ascii_DOLLAR

/n_scriptOptions/proc/IsValidIDChar(char) //returns true if the character can be in the body of a variable, function, or keyword name (by default letters, numbers, and underscore)
	if(!isnum(char))char=text2ascii(char)
	return CanStartID(char) || IsDigit(char)

/n_scriptOptions/proc/IsDigit(char)
	if(!isnum(char))char=text2ascii(char)
	return char in ascii_ZERO to ascii_NINE

/n_scriptOptions/proc/IsValidID(id)    //returns true if all the characters in the string are okay to be in an identifier name
	if(!CanStartID(id)) //don't need to grab first char in id, since text2ascii does it automatically
		return 0
	if(length(id)==1) return 1
	for(var/i=2 to length(id))
		if(!IsValidIDChar(copytext(id, i, i+1)))
			return 0
	return 1

/*
	Class: nS_Options
	An implementation of <n_scriptOptions> for the n_Script language.
*/
/n_scriptOptions/nS_Options
	var/list/symbols = list("(", ")", "\[", "]", ";", ",", "{", "}")     										//scanner - Characters that can be in symbols
/*
	Var: keywords
	An associative list used by the parser to parse keywords. Indices are strings which will trigger the keyword when parsed and the
	associated values are <nS_Keyword> types of which the <n_Keyword.Parse()> proc will be called.
*/
	var/list/keywords						= list(	"if"		= /n_Keyword/nS_Keyword/kwIf,		"else"  = /n_Keyword/nS_Keyword/kwElse, \
													"while"	= /n_Keyword/nS_Keyword/kwWhile,		"break"	= /n_Keyword/nS_Keyword/kwBreak, \
													"continue" = /n_Keyword/nS_Keyword/kwContinue,	"return"	= /n_Keyword/nS_Keyword/kwReturn,\
													"def"   = /n_Keyword/nS_Keyword/kwDef
													)

	var/list/assign_operators = list(			"="  = null, 					"&=" = "&",
											 			"|=" = "|","`=" = "`",
														"+=" = "+","-=" = "-",
														"*=" = "*","/=" = "/",
														"^=" = "^",
														"%=" = "%")

	var/list/unary_operators = list("!"  = /node/expression/c_operator/unary/LogicalNot, 		 "~"  = /node/expression/c_operator/unary/BitwiseNot,
														"-"  = /node/expression/c_operator/unary/Minus)

	var/list/binary_operators = list("==" = /node/expression/c_operator/binary/Equal, 			   "!="	= /node/expression/c_operator/binary/NotEqual,
														">"  = /node/expression/c_operator/binary/Greater, 			 "<" 	= /node/expression/c_operator/binary/Less,
														">=" = /node/expression/c_operator/binary/GreaterOrEqual,"<=" = /node/expression/c_operator/binary/LessOrEqual,
														"&&" = /node/expression/c_operator/binary/LogicalAnd,  	 "||"	= /node/expression/c_operator/binary/LogicalOr,
														"&"  = /node/expression/c_operator/binary/BitwiseAnd,  	 "|" 	= /node/expression/c_operator/binary/BitwiseOr,
														"`"  = /node/expression/c_operator/binary/BitwiseXor,  	 "+" 	= /node/expression/c_operator/binary/Add,
														"-"  = /node/expression/c_operator/binary/Subtract, 		 "*" 	= /node/expression/c_operator/binary/Multiply,
														"/"  = /node/expression/c_operator/binary/Divide, 			 "^" 	= /node/expression/c_operator/binary/Power,
														"%"  = /node/expression/c_operator/binary/Modulo)

/n_scriptOptions/nS_Options/New()
	.=..()
	for(var/O in assign_operators+binary_operators+unary_operators)
		if(!list_find(symbols, O)) symbols+=O
