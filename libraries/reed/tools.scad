module stack(heights) { // heights is a list of heights of child objects
	for(i = [0 : $children - 1]) {
		if(i == 0) {
			children(i);
		} else {
			translate([0, 0, heights[i - 1]])
				children(i);
		}
	}
}