#ifndef SPACEMAN_DMM

#pragma FileAlreadyIncluded error
#pragma MissingIncludedFile error
#pragma MisplacedDirective error
#pragma UndefineMissingDirective error
#pragma DefinedMissingParen error
#pragma ErrorDirective error
#pragma WarningDirective error
#pragma MiscapitalizedDirective error

// 2000-2999
#pragma SoftReservedKeyword error
#pragma DuplicateVariable error
#pragma DuplicateProcDefinition error
#pragma TooManyArguments error
#pragma PointlessParentCall error
#pragma PointlessBuiltinCall notice
#pragma SuspiciousMatrixCall error
#pragma MalformedRange error
#pragma InvalidRange error
#pragma InvalidSetStatement error
#pragma InvalidOverride error
#pragma DanglingVarType error
#pragma MissingInterpolatedExpression error

// 3000-3999
#pragma EmptyBlock notice

#pragma OD3100

world
	var/timezone

/datum/controller/master
	var/const/tick_limit_default = 80

#endif
