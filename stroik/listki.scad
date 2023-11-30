include <reed/reed.scad>
include <variants.scad>

$fn=100;

max_in_a_row = 6;

thickness_offsets = [-0.2, 0, 0.2, 0.4, 1];
degree_offsets = [-1, -0.50, 0, 0.5, 1];
// degree_offsets = [0];
// thickness_offsets = [0];


leaf_variants = [for(thoff = thickness_offsets) for(doff = degree_offsets) for(v = variants) [v[0], v[1], v[2], v[3], v[4], v[5], v[6], doff, thoff]];
echo(leaf_variants);

for (i = [0 : len(leaf_variants) - 1]){
    v = leaf_variants[i];
    echo(str("variant: ", v));
    translate([(i % max_in_a_row) * 12, (floor(i / max_in_a_row)) * 12, 0]){
        leaf(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8]);
    }
}
