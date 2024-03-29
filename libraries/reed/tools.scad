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

module arrange(spacing=50, n=5) {
    nparts = $children;
    for(i=[0:1:n-1], j=[0:nparts/n])
        if (i+n*j < nparts)
            translate([spacing*(i+1), spacing*j, 0])
                children(i+n*j);
}
