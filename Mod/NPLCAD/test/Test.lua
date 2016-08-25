union();
function createObj(value,_color,direction)
    color(_color[1],_color[2],_color[3]);
    local x = 0;
    local y = 0;
    local z = 0;
    for k = 0, 9 do
        if(direction == "y")then
            y = y + value;
        elseif(direction == "z")then
            z = z + value;
        else
            x = x + value;
        end
        
        push();
            translate(x,y,z);
            cube();
        pop();
    end    
end
createObj(3,{1,0,0});
createObj(3,{0,1,0},"y");
createObj(3,{0,0,1},"z");
createObj(-3,{1,0,0});
createObj(-3,{0,1,0},"y");
createObj(-3,{0,0,1},"z");