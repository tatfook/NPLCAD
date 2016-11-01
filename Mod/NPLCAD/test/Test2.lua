--[[
Title: Test npl request 
Author(s): leio
Date: 2016/11/1
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/test/Test2.lua");
local Test2 = commonlib.gettable("Nplcad.Test2");	
Test2.Call();
------------------------------------------------------------
--]]


local Test2 = commonlib.gettable("Nplcad.Test2");	
function Test2.Call()
	NPL.load("(gl)script/ide/Encoding.lua");
	local Encoding = commonlib.gettable("commonlib.Encoding");
	local code = [[
push();
    color("red");
    union();
    cube();
    sphere();
pop();
    translate({4,0,0});
        push();
            color("green");
            difference();
            cube();
            sphere();
        pop();
        translate({4,0,0});
            push();
                color("blue");
                intersection();
                cube();
                sphere();
            pop();
]]
	code = Encoding.url_encode(code)
	commonlib.echo("============code");
	commonlib.echo(code);
	local url = string.format("http://localhost:8099/nplcad?code=%s",code);
	ParaGlobal.ShellExecute("open", "iexplore.exe", url, "", 1);
end
