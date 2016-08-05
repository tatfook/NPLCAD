angular.module('NPLCAD_App', ['ngStorage','ngAnimate', 'ui.bootstrap'])
 .controller('nplcadController', function ($scope, $http, $log) {
	$scope.isCollapsed = true;
	$scope.isCollapsedHorizontal = false;
	
	  $scope.status = {
    isopen: false
  };

  $scope.toggled = function(open) {
    $log.log('Dropdown is now: ', open);
  };

  $scope.toggleDropdown = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.status.isopen = !$scope.status.isopen;
  };

  $scope.appendToEl = angular.element(document.querySelector('#dropdown-long-content'));
		
    if (Page)
        Page.ShowSideBar(false);
    window.URL = window.URL || window.webkitURL;
    window.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder;

    Number.prototype.format = function () {
        return this.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
    };

    //
    var rendererTypes = {

        'WebGLRenderer': THREE.WebGLRenderer,
        'CanvasRenderer': THREE.CanvasRenderer,
        'SVGRenderer': THREE.SVGRenderer,
        'SoftwareRenderer': THREE.SoftwareRenderer,
        'RaytracingRenderer': THREE.RaytracingRenderer

    };
    var editor = new Editor();
    var viewport = new Viewport(editor);
    $("#view_container").append(viewport.dom);


    var type = "WebGLRenderer";
    var renderer = new rendererTypes[type]();

    var last_mesh;
    var signals = editor.signals;
    signals.rendererChanged.dispatch(renderer);
    editor.setTheme("css/light.css");

    //light
    var hemiLight = new THREE.HemisphereLight(0xffffff, 0xffffff, 0.6);
    hemiLight.color.setHSL(0.6, 1, 0.6);
    hemiLight.groundColor.setHSL(0.095, 1, 0.75);
    hemiLight.position.set(0, 500, 0);
    editor.addObject(hemiLight);

    var dirLight = new THREE.DirectionalLight(0xffffff, 1);
    dirLight.color.setHSL(0.1, 1, 0.95);
    dirLight.position.set(-1, 1.75, 1);
    dirLight.position.multiplyScalar(50);
    editor.addObject(dirLight);

    function onWindowResize(event) {
        editor.signals.windowResize.dispatch();
    }

    window.addEventListener('resize', onWindowResize, false);

    function createMesh(vertices, indices, normals, colors) {
        if (last_mesh) {
            editor.removeObject(last_mesh);
        }
        var geometry = new THREE.BufferGeometry();
        var vertices_arr = [];
        var indices_arr = [];
        var colors_arr = [];
        for (var i = 0; i < vertices.length; i++) {
            vertices_arr.push(vertices[i][0], vertices[i][1], vertices[i][2]);
        }
        for (var i = 0; i < indices.length; i++) {
            indices_arr.push(indices[i] - 1);
        }
        for (var i = 0; i < colors.length; i++) {
            colors_arr.push(colors[i][0], colors[i][1], colors[i][2]);
        }
        var geometry = new THREE.BufferGeometry();
        geometry.setIndex(new THREE.BufferAttribute(new Uint16Array(indices_arr), 1));
        geometry.addAttribute('position', new THREE.BufferAttribute(new Float32Array(vertices_arr), 3));
        geometry.addAttribute('color', new THREE.BufferAttribute(new Float32Array(colors_arr), 3));
        geometry.computeBoundingSphere();


        var material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
        last_mesh = new THREE.Mesh(geometry, material);
        editor.addObject(last_mesh);
        geometry = new THREE.Geometry().fromBufferGeometry(geometry);
        return geometry;
    }
    function stlFromGeometry(geometry, options) {

        geometry.computeFaceNormals()

        var addX = 0
        var addY = 0
        var addZ = 0
        var download = false

        if (options) {
            if (options.useObjectPosition) {
                addX = geometry.mesh.position.x
                addY = geometry.mesh.position.y
                addZ = geometry.mesh.position.z
            }

            if (options.download) {
                download = true
            }
        }


        var facetToStl = function (verts, normal) {
            var faceStl = ''
            faceStl += 'facet normal ' + normal.x + ' ' + normal.y + ' ' + normal.z + '\n'
            faceStl += 'outer loop\n'

            for (var j = 0; j < 3; j++) {
                var vert = verts[j]
                faceStl += 'vertex ' + (vert.x + addX) + ' ' + (vert.y + addY) + ' ' + (vert.z + addZ) + '\n'
            }

            faceStl += 'endloop\n'
            faceStl += 'endfacet\n'

            return faceStl
        }

        // start bulding the STL string
        var stl = ''
        stl += 'solid\n'

        for (var i = 0; i < geometry.faces.length; i++) {
            var face = geometry.faces[i]

            // if we have just a griangle, that's easy. just write them to the file
            if (face.d === undefined) {
                var verts = [
                    geometry.vertices[face.a],
                    geometry.vertices[face.b],
                    geometry.vertices[face.c]
                ]

                stl += facetToStl(verts, face.normal)

            } else {
                // if it's a quad, we need to triangulate it first
                // split the quad into two triangles: abd and bcd
                var verts = []
                verts[0] = [
                    geometry.vertices[face.a],
                    geometry.vertices[face.b],
                    geometry.vertices[face.d]
                ]
                verts[1] = [
                    geometry.vertices[face.b],
                    geometry.vertices[face.c],
                    geometry.vertices[face.d]
                ]

                for (var k = 0; k < 2; k++) {
                    stl += facetToStl(verts[k], face.normal)
                }

            }
        }

        stl += 'endsolid'

        if (download) {
			var sFileName = document.getElementById('wtf').value;
			if (sFileName){
				var blob = new Blob([stl], {type: 'text/plain'});
				saveAs(blob, sFileName + '.stl');
			}
			else alert("Please enter file name!");
        }

        return stl
    }
    
	
	
	var code_editor = ace.edit("code_editor");
    code_editor.setTheme("ace/theme/github");
    code_editor.getSession().setMode("ace/mode/lua");
    code_editor.setShowPrintMargin(false);

	
	$scope.changeEditorContent = function(num) { 
	if(num){
	var sContent = angular.element(document.getElementById('code_example'+num)).text();
	if(sContent){
		code_editor.setValue(sContent) ;
	}
	else alert("Can't find code example");
	}
	}
	$scope.editText = function(check) { 
	var oInput = angular.element(document.getElementsByName(check+'Input'));
	var atxt = new Array();
	if(oInput){
		for (var i=0;i<oInput.length;i++){
			atxt[i]=oInput[i].value
		}
		var txt = "{ center = {"+atxt[0]+","+atxt[1]+","+atxt[2]+"}, radius = {"+atxt[3]+","+atxt[4]+","+atxt[5]+"}};"
		alert (txt);
	}
	else return
	}  

    $scope.onRunCode = function (bSave) {
        $("#logWnd").html("");
        var text = code_editor.getValue();
        $http.get("ajax/nplcad?action=runcode&code=" + encodeURIComponent(text)).then(function (response) {
            if (response && response.data && response.data.result) {
                if (response.data.success) {
                    var vertices = response.data.result[0];
                    var indices = response.data.result[1];
                    var normals = response.data.result[2];
                    var colors = response.data.result[3];

                    var geometry = createMesh(vertices, indices, normals, colors);
                    if (bSave) {
                        stlFromGeometry(geometry, { download: true })
                    }

                }else{
                    $("#logWnd").html(response);
                }
                
            } else {
                $("#logWnd").html("error!");
            }
        });
    }

    onWindowResize();
});



























