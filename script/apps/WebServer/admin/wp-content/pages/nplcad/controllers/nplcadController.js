var nplcadModule = angular.module('NPLCAD_App', ['ngStorage', 'ngAnimate', 'ui.bootstrap','ui.bootstrap.materialPicker']);
nplcadModule.component("nplcad", {
    templateUrl: "/wp-content/pages/nplcad/templates/nplcadTemplate.html",
    controller:function ($scope, $http, $log) {
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
            var container, stats;
            var camera, scene, renderer;
            var controls, transformControl;
            var meshes = [];
            init();
            animate();
            function init() {
                container = document.createElement('div');
                container.style["position"] = "relative";
                container.style["width"] = "100%";
                container.style["height"] = "560px";
                $("#view_container").append(container);
                scene = new THREE.Scene();
                camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10000);
                camera.position.set(10, 5, 10);
                camera.lookAt(new THREE.Vector3());
                scene.add(camera);

                // light
                scene.add(new THREE.HemisphereLight(0x443333, 0x111122));
                addShadowedLight(1, 1, 1, 0xffffff, 1.35);
                addShadowedLight(0.5, 1, -1, 0xffaa00, 1);

                var helper = new THREE.GridHelper(30, 1);
                helper.material.opacity = 0.25;
                helper.material.transparent = true;
                scene.add(helper);

                renderer = new THREE.WebGLRenderer({ antialias: true });
                renderer.setClearColor(0xf0f0f0);
                renderer.setPixelRatio(window.devicePixelRatio);
                renderer.setSize(window.innerWidth, window.innerHeight);
                renderer.gammaInput = true;
                renderer.gammaOutput = true;
                renderer.shadowMap.enabled = true;
                renderer.shadowMap.renderReverseSided = false;
                container.appendChild(renderer.domElement);

                // Controls
                controls = new THREE.OrbitControls(camera, renderer.domElement);
                controls.damping = 0.2;
                controls.addEventListener('change', render);

                transformControl = new THREE.TransformControls(camera, renderer.domElement);
                transformControl.addEventListener('change', render);

                scene.add(transformControl);
                window.addEventListener('resize', onWindowResize, false);
                onWindowResize();
            }
            function onWindowResize() {

                var w = container.offsetWidth;
                var h = container.offsetHeight;
                //var w = window.innerWidth;
                //var h = window.innerHeight;
                camera.aspect = w / h;
                camera.updateProjectionMatrix();

                renderer.setSize(w, h);

            }
            function animate() {

                requestAnimationFrame(animate);
                render();
                controls.update();
                transformControl.update();

            }

            function render() {
                renderer.render(scene, camera);
            }
            function removeObject(object) {
                if (object.parent === null) return; 
                object.parent.remove(object);
            }
            function clearMeshes(){
                for (var i = 0; i < meshes.length; i++) {
                    removeObject(meshes[i]);
                }
				//array.slice()并不删除数组
                meshes.splice(0,meshes.length);
            }
			$scope.clearMesh = function(){
				for (var i = 0; i < meshes.length; i++) {
                    removeObject(meshes[i]);
                }
				//array.slice()并不删除数组
                meshes.splice(0,meshes.length);
			}
			function addShadowedLight( x, y, z, color, intensity ) {

			    var directionalLight = new THREE.DirectionalLight( color, intensity );
			    directionalLight.position.set( x, y, z );
			    scene.add(directionalLight);

			    directionalLight.castShadow = true;

			    var d = 1;
			    directionalLight.shadow.camera.left = -d;
			    directionalLight.shadow.camera.right = d;
			    directionalLight.shadow.camera.top = d;
			    directionalLight.shadow.camera.bottom = -d;

			    directionalLight.shadow.camera.near = 1;
			    directionalLight.shadow.camera.far = 4;

			    directionalLight.shadow.mapSize.width = 1024;
			    directionalLight.shadow.mapSize.height = 1024;

			    directionalLight.shadow.bias = -0.005;

			}

			// convert data calculated by CSG.lua to THREE.js, render
            function createMesh(vertices, indices, normals, colors, world_matrix) {
                var geometry = new THREE.BufferGeometry();
                var vertices_arr = [];
                var indices_arr = [];
                var normals_arr = [];
                var colors_arr = [];
                for (var i = 0; i < vertices.length; i++) {
                    var x = vertices[i][0];
                    var y = vertices[i][1];
                    var z = vertices[i][2];
                    var pos = new THREE.Vector3(x, y, z);
                    if (world_matrix) {
                        pos.applyMatrix4(world_matrix);
                    }
                    vertices_arr.push(pos.x, pos.y, pos.z);
                }
                for (var i = 0; i < indices.length; i++) {
                    indices_arr.push(indices[i] - 1);
                }
                for (var i = 0; i < normals.length; i++) {
                    normals_arr.push(normals[i][0], normals[i][1], normals[i][2]);
                }
                for (var i = 0; i < colors.length; i++) {
                    colors_arr.push(colors[i][0], colors[i][1], colors[i][2]);
                }
                var geometry = new THREE.BufferGeometry();
                geometry.setIndex(new THREE.BufferAttribute(new Uint16Array(indices_arr), 1));
                geometry.addAttribute('position', new THREE.BufferAttribute(new Float32Array(vertices_arr), 3));
                geometry.addAttribute('normal', new THREE.BufferAttribute(new Float32Array(normals_arr), 3));
                geometry.addAttribute('color', new THREE.BufferAttribute(new Float32Array(colors_arr), 3));
                geometry.computeBoundingSphere();


                var material = new THREE.MeshPhongMaterial({ vertexColors: THREE.VertexColors, shininess: 200 });
                //var material = new THREE.MeshBasicMaterial({ color: 0xffffff, vertexColors: THREE.VertexColors });

				
                var mesh = new THREE.Mesh(geometry, material);
                mesh.castShadow = true;
                mesh.receiveShadow = true;

                scene.add(mesh);
                meshes.push(mesh);
                
                return geometry;
            }
			//save several geometries in one stl file
            function stlFromGeometries(geometries, options) {
                // start bulding the STL string
                var stl = ''
                stl += 'solid\n'
                for (var i = 0; i < geometries.length; i++) {
                    var s = stlFromGeometry(geometries[i], options);
                    stl += s;
                }
                stl += 'endsolid'

                if (options.download) {
                    var sFileName = document.getElementById('wtf').value;
                    if (sFileName) {
                        var blob = new Blob([stl], { type: 'text/plain' });
                        saveAs(blob, sFileName + '.stl');
                    }
                    else alert("Please enter file name!");
                }

                return stl
            }
            function stlFromGeometry(geometry, options) {
				geometry = new THREE.Geometry().fromBufferGeometry(geometry);
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
                }

                var facetToStl = function (verts, normal) {
                    var faceStl = ''
                    faceStl += 'facet normal ' + normal.x + ' ' + normal.y + ' ' + normal.z + '\n'
                    faceStl += 'outer loop\n'


                    if (options.isYUp) {
                        faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + '\n'
                        faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + '\n'
                        faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + '\n'
                    } else {
                        // invert y,z and change the triangle winding
                        faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + '\n'
                        faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + '\n'
                        faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + '\n'
                    }

                    faceStl += 'endloop\n'
                    faceStl += 'endfacet\n'

                    return faceStl
                }

                var stl = ''

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
                return stl;
            }

			// Stl to geometry
			var aStlGeometry;
			function stlToGeometry(){
				var stlFile = document.getElementById('stlFile').files[0];
				var loader = new THREE.STLLoader();
				var reader = new FileReader();
				reader.readAsArrayBuffer(stlFile);
				
				reader.onload = function(){
				var data = reader.result;
				if(data){
					var geometry = loader.parse(data);
					aStlGeometry = geometry;
					var material = new THREE.MeshPhongMaterial({ vertexColors: THREE.VertexColors, shininess: 200 });
				
					var mesh = new THREE.Mesh(geometry, material);
					scene.add(mesh);
					meshes.push(mesh);
				}
				else alert('Loading failed')
				};
			}
			$scope.addStl = function(){
				stlToGeometry();
				
			}
            var code_editor = ace.edit("code_editor");
            code_editor.setTheme("ace/theme/github1");
            code_editor.getSession().setMode("ace/mode/lua");
            code_editor.setShowPrintMargin(false);

			//get CSG code examples from nplcadTemplate div and send it to code_editor
            $scope.changeEditorContent = function(num) { 
                if(num){
                    var sContent = angular.element(document.getElementById('code_example'+num)).text();
                    if(sContent){
                        code_editor.setValue(sContent) ;
                    }
                    else alert("Can't find code example");
                }
            }
			

		
			var aGeometries = [];
            function onRunCode(isNewVersion) {
                $("#logWnd").html("");
                var text = code_editor.getValue();
                var v = 1;
                if (isNewVersion) {
                    v = 2;
                }
                $http.get("ajax/nplcad?action=runcode&v=" + v + "&code=" + encodeURIComponent(text)).then(function (response) {
                    if (response && response.data && response.data.csg_node_values) {
                        console.log(response.data);
                        clearMeshes();
                        if (response.data.successful) {
                            var csg_node_values = response.data.csg_node_values;
                            
                            for (var i = 0; i < csg_node_values.length; i++) {
                                var value = csg_node_values[i];
                                var vertices = value.vertices;
                                var indices = value.indices;
                                var normals = value.normals;
                                var colors = value.colors;
                                var world_matrix;
                                if (value.world_matrix) {
                                    world_matrix = new THREE.Matrix4();
                                    world_matrix = world_matrix.fromArray(value.world_matrix);
                                }
                                var geometry = createMesh(vertices, indices, normals, colors, world_matrix);
								aGeometries = [];
								if(aStlGeometry){
									aGeometries.push(aStlGeometry);
								}								
                                aGeometries.push(geometry);
                            }
                        }else{
                            $("#logWnd").html(response.data.compile_error);
                        }
                
                    } else {
                        $("#logWnd").html("error!");
                    }
                });
            }
            $scope.onRunCode = function (isNewVersion) {
                onRunCode(isNewVersion);
			}
			$scope.onSaveCode = function(){
				if(aGeometries){
					if(aStlGeometry){
						aGeometries.push(aStlGeometry);	
					}				
					stlFromGeometries(aGeometries, { download: true });
				}
				else{
					alert("Please compile the code before save.")
				}
			}			
        }
    })

nplcadModule.component("first",{
	templateUrl: "/wp-content/pages/nplcad/templates/first.html",
    controller:function () {
		window.onload = function(){
		var panel = document.getElementById('panel'),
        menu = document.getElementById('menu'),
        showcode = document.getElementById('showcode'),
		view_container = document.getElementById('view_container'),
        selectFx = document.getElementById('selections-fx'),
        selectPos = document.getElementById('selections-pos'),
        // demo defaults
        effect = 'mfb-zoomin',
        pos = 'mfb-component--br';
	var isBlock;
    showcode.addEventListener('click', _toggleCode);
	view_container.addEventListener('click', hideCode);
   
	
    function _toggleCode() {
		isBlock = panel.classList.toggle('viewCode');
	 
    }
	function hideCode(){
		if(isBlock){
			isBlock = panel.classList.toggle('viewCode');
		}
	}
    function switchEffect(e){
      effect = this.options[this.selectedIndex].value;
      renderMenu();
    }

    function switchPos(e){
      pos = this.options[this.selectedIndex].value;
      renderMenu();
    }

    function renderMenu() {
      menu.style.display = 'none';
      // ?:-)
      setTimeout(function() {
        menu.style.display = 'block';
        menu.className = pos + effect;
      },1);
    }
}
	}
})


nplcadModule.component("example",{
	templateUrl: "/wp-content/pages/nplcad/templates/example.html"
})













