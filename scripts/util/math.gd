class_name Math

static func ilog2(x: int) -> int:
	var f = log(x) / log(2)
	return int(f)
