class_name GlobalUtils extends Node

func random_pick( elements , probabilities ) :
	var n = min(elements.size(), probabilities.size())
	var p = probabilities.duplicate()
	for i in range(n-1):
		p[i+1] += p[i]
	var k = randi_range(0,p[n-1])
	print(k, p)
	for i in range(n):
		if k <= p[i]:
			return elements[i]
	return elements[0]
