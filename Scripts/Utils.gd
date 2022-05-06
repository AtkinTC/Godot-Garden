class_name Utils

static func format_comma_seperated(number : String) -> String:
	var number_string = str(number)
	var parts := number_string.split(".")
	
	if(parts.size() == 0):
		return number_string
	
	var pre = parts[0]
	var pos = pre.length() - 3
	while(pos > 0):
		pre = pre.insert(pos, ",")
		pos -= 3
	
	if(parts.size() == 2):
		var post = parts[1]
		return pre + "." + post
		
	return pre
