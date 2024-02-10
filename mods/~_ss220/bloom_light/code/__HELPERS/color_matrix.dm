/datum/ColorMatrix
	var/list/matrix
	var/combined = 1
	var/const/lumR = 0.3086 //  or  0.2125
	var/const/lumG = 0.6094 //  or  0.7154
	var/const/lumB = 0.0820 //  or  0.0721

/datum/ColorMatrix/New(mat, contrast = 1, brightness = null)
	..()

	if(istext(mat))
		if(!matrix)
			SetColor(mat, contrast, brightness)
	else if(isnum(mat))
		SetSaturation(mat, contrast, brightness)
	else
		matrix = mat

/datum/ColorMatrix/proc/Reset()
	matrix = list(1,0,0,
				  0,1,0,
				  0,0,1)

/datum/ColorMatrix/proc/Get(contrast = 1)
	var/list/mat = matrix
	mat = mat.Copy()

	for(var/i = 1 to min(length(mat), 12))
		mat[i] *= contrast

	return mat

/datum/ColorMatrix/proc/SetSaturation(s, c = 1, b = null)
	var/sr = (1 - s) * lumR
	var/sg = (1 - s) * lumG
	var/sb = (1 - s) * lumB

	matrix = list(c * (sr + s), c * (sr),     c * (sr),
				  c * (sg),     c * (sg + s), c * (sg),
				  c * (sb),     c * (sb),     c * (sb + s))

	SetBrightness(b)

/datum/ColorMatrix/proc/SetBrightness(brightness)
	if(isnull(brightness)) return

	if(!matrix)
		Reset()

	var/matrixlen = length(matrix)

	if(matrixlen == 9 || matrixlen == 16)
		matrix += brightness
		matrix += brightness
		matrix += brightness

		if(matrixlen == 16)
			matrix += 0

	else if(matrixlen == 12)
		for(var/i = matrixlen to matrixlen - 3 step -1)
			matrix[i] = brightness

	else if(matrixlen == 3)
		for(var/i = matrixlen - 1 to matrixlen - 4 step -1)
			matrix[i] = brightness

/datum/ColorMatrix/proc/hex2value(hex)
	var/num1 = copytext(hex, 1, 2)
	var/num2 = copytext(hex, 2)

	if(isnum(text2num(num1)))
		num1 = text2num(num1)
	else
		num1 = text2ascii(lowertext(num1)) - 87

	if(isnum(text2num(num1)))
		num2 = text2num(num1)
	else
		num2 = text2ascii(lowertext(num2)) - 87

	return num1 * 16 + num2

/datum/ColorMatrix/proc/SetColor(color, contrast = 1, brightness = null)
	var/rr = hex2value(copytext(color, 2, 4)) / 255
	var/gg = hex2value(copytext(color, 4, 6)) / 255
	var/bb = hex2value(copytext(color, 6, 8)) / 255

	rr = round(rr * 1000) / 1000 * contrast
	gg = round(gg * 1000) / 1000 * contrast
	bb = round(bb * 1000) / 1000 * contrast

	matrix = list(rr, gg, bb,
				  rr, gg, bb,
				  rr, gg, bb)

	SetBrightness(brightness)
