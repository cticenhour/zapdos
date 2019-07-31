dom0Mult = 1/25.4e-3;
//dom0Mult = 1;

//Bottom center
Point(1) = {0, 0, 0, 2e-3};
//Mid center
Point(2) = {0, 12.7e-3 * dom0Mult, 0, 50e-2};
//Top center
Point(3) = {0, 25.4e-3 * dom0Mult, 0, 1e-3};
//Top Edge
Point(4) = {25.4e-3 * dom0Mult, 25.4e-3 * dom0Mult, 0, 1e-3};
//Mid Edge
Point(5) = {25.4e-3 * dom0Mult, 12.7e-3 * dom0Mult, 0, 50e-2};
//Bottom Edge
Point(6) = {25.4e-3 * dom0Mult, 0, 0, 2e-3};

//Axis of symmetry
Line(11) = {1,2};
Line(12) = {2,3};

//Top Cathode
Line(13) = {3,4};

//Edge
Line(14) = {4,5};
Line(15) = {5,6};

//Bottom Cathode
Line(16) = {6,1};

Line Loop(21) = {11, 12, 13, 14, 15, 16};
Plane Surface(31) = {21};

// Plasma domain
Physical Surface("plasma") = {31};

// Physical Cathode
Physical Line("top_plate") = {13};

// Physical Anode
Physical Line("bottom_plate") = {16};

// Physical Walls
Physical Line("edge") = {14, 15};

// Physical axis of symmetry
Physical Line("axis") = {11,12};
