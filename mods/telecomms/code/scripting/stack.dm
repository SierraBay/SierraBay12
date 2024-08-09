/stack
	var/list/contents=new
/stack/proc/Push(value)
	contents+=value

/stack/proc/Pop()
	if(!LAZYLEN(contents))
		return null
	. = contents[LAZYLEN(contents)]
	LIST_RESIZE(contents, LAZYLEN(contents) - 1)

/stack/proc/Top() //returns the item on the top of the stack without removing it
	if(!LAZYLEN(contents)) return null
	return contents[LAZYLEN(contents)]

/stack/proc/Copy()
	var/stack/S=new()
	S.contents=src.contents.Copy()
	return S

/stack/proc/Clear()
	contents.Cut()
