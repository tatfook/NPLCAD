color(1,0,0);
translate(2,0,3);
push();
    rotate(45,0,0);
    color(1,1,0);
    cube({1,1,1},{0,3,0});
    push()
        translate(5,0,0);
        cube({1,1,1},{0,6,0});
    pop();
pop();
sphere(1,16,16,{-3,0,0});
cylinder({0,-1,0},{0,1,0},1,16);
cube(nil,{5,0,0});