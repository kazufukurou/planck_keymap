// -*- mode: c -*-
/* All distances are in mm. */

$fn = 50;
angle = 10;
thumb_angle = 20;
hole_radius = 1.5;
washer_radius = 4 * hole_radius;
hand_distance = 8;
spacing = 19;
space_size = spacing + 1;
switch_size = 13.97;
key_size = 17;
rows = 4;
cols = 6;
row_offsets = [0, 0, 0, 4, 0, -4];

module rz(angle, center=undef) translate(center) rotate(angle) translate(-center) children();
module mirrored() { children(); mirror ([1,0,0]) { children(); } }
module key(pos, size) translate(pos) square([size, size], center=true);
module hole(pos, size) translate(pos) circle(size);
module add_hand_distance() translate([0.5 * hand_distance, 0]) children();
module rotate_half() add_hand_distance() rz(angle, [hand_distance, spacing]) children();
module plate_bottom() difference() { hull() { holes(washer_radius); } holes(hole_radius); }
module plate_top() difference() { plate_bottom(); keys(switch_size); }

module keys(size) mirrored() rotate_half() {
  o = spacing*0.5;
  for (c=[1:(cols-1)]) for(r=[1:(rows-1)]) key([c*spacing + o, r*spacing + row_offsets[c] + o], size);
  //for (c=[2:(cols-2)]) key([c*spacing + o, row_offsets[c] + o], size);
  for (c=[2:(cols-3)]) key([c*spacing + o, o], size);
  rz(thumb_angle, [2*spacing, 0]) {
    key([spacing + o, o], size);
    rz(thumb_angle, [spacing, 0]) key([o, o], size);
  }
}

module holes(radius) mirrored() {
  //translate([0, 30]) square([15, 30], center=true);
  o = 6;
  top_corner = [cols * spacing + o, rows*spacing + row_offsets[cols-1]];
  rotate_half() {
    hole(top_corner, radius);
    hole([cols * spacing + o, spacing + row_offsets[cols-1]], radius);
    rz(thumb_angle, [2*spacing, 0]) rz(thumb_angle, [spacing, 0]) hole([o, row_offsets[0] - o], radius);
  }
  translate([(-spacing*4 - o*2) / cos(angle), 0]) rotate_half() hole(top_corner, radius);
}

module plate_middle() difference() {
  linear_extrude(height=8, center=true, convexity=10, twist=0) difference() {
    union() {
      difference() {
        plate_bottom();
        hull() keys(key_size+3);
        mirrored() polygon([[0, 85],[-112,89],[-122,35],[0,0]]);
        //hull() translate([-6,0]) keys(key_size);
      }
      holes(washer_radius);
      translate([0, 85]) polygon([[-20, -5],[20,-5],[32,7],[-32,7]]);
    }
    holes(hole_radius);
    translate([0, 93]) square([38,  12], center=true);
    //translate([0, 93]) square([14, 30], center=true);
    //translate([0, -50]) square([200, 200], center=false);
  }
  mirrored() translate([-14, 95]) rotate([90,0,0]) cylinder(r=1.5,h=30);
  translate([0, 93]) cube([12, 30, 4], center=true);
}

plate_top();
translate([0, 130]) plate_bottom();
translate([300, 0]) plate_middle();
