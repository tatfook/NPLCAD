var nplcadModule = angular.module('NPLCAD_App', ['ngStorage', 'ngSanitize', 'ngAnimate', 'ui.bootstrap']);
nplcadModule.service('voxelService', function () {
    var self = this;
    var container, stats;
    var camera, scene, renderer;
    var controls, transformControl;
    var meshes = [];
    var supported_extensions = ["stl", "bmax"];

    var axisMonitor;
    var is_init = false;
    this.slider_value = 16;
    this.init = function () {
        if (is_init) {
            return
        }
        is_init = true;

        container = document.createElement('div');
        container.style["position"] = "relative";
        container.style["width"] = "100%";
        container.style["height"] = "300px";
        $("#voxel_view_container").append(container);
        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10000);
        camera.position.set(10, 15, 10);
        camera.lookAt(new THREE.Vector3());
        camera.up.set(0, 1, 0);
        scene.add(camera);
        this.camera = camera;

        // light
        var ambientLight = new THREE.AmbientLight(0x444444);
        ambientLight.name = 'ambientLight';
        scene.add(ambientLight);

        var directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position.x = 17;
        directionalLight.position.y = 30;
        directionalLight.position.z = 9;
        directionalLight.name = 'directionalLight';
        scene.add(directionalLight);

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

        axisMonitor = new THREE.AxisMonitor("voxel_axis_container",80,80);

        // Controls
        controls = new THREE.OrbitControls(camera, renderer.domElement);
        controls.damping = 0.2;
        controls.mouseButtons.ORBIT = THREE.MOUSE.RIGHT;
        controls.mouseButtons.PAN = THREE.MOUSE.LEFT;
        controls.keys.LEFT = 65;
        controls.keys.RIGHT = 68;
        controls.keys.UP = 32;
        controls.keys.BOTTOM = 88;
        controls.keys.FOREWARD = 87;
        controls.keys.BACKWARD = 83;
        controls.addEventListener('change', render);

        transformControl = new THREE.TransformControls(camera, renderer.domElement);
        transformControl.addEventListener('change', render);

        scene.add(transformControl);
        window.addEventListener('resize', onWindowResize, false);
        onWindowResize();

        animate();


       
    }
    this.show = function (input_file_name, input_format, input_content, output_format) {
        this.input_file_name = input_file_name;
        this.input_format = input_format;
        this.input_content = input_content;
        this.output_format = output_format;
        this.voxelizer();
    }
    this.setSliderValue = function (v) {
        this.slider_value = v;

        if (!this.is_loading) {
            this.preview_stl_content = null;
            this.output_content = null;
            clearMeshes();
            this.voxelizer()
        }

    }
    function get_filename_ext(fileName) {
        var name = fileName.substr(0, fileName.lastIndexOf('.'));
        var ext = fileName.substr(fileName.lastIndexOf('.') + 1);
        return [name, ext];
    }
    this.saveFile = function () {
        var fileName = this.input_file_name;
        var output_format = this.output_format;
        var arr = get_filename_ext(fileName);
        var name = arr[0];
        var ext = arr[1];

        name = name + "." + output_format;
        console.log("onSave:", name);
        if (this.output_content) {
            var url = "ajax/nplcad?action=nplcad_savefile";
            var data = {
                content: this.output_content,
                filename: name
            };
            $.post(url, data).then(function (response) {
                if (response && response[0]) {
                    $.notify("bmax file was saved to: " + name, { type: "success" });
                }
                console.log(response);
            })

            //var blob = new Blob([this.output_content], { type: 'text/plain' });
            //saveAs(blob, name);
        }
    }
    this.voxelizer_request = function (callback) {
        var url = "ajax/nplvoxelizer?action=nplvoxelizer_voxelizer";
        console.log("voxelizer request data length:", this.input_content.length, "block_length:", this.slider_value, "input_format:", this.input_format, "output_format:", this.output_format);
        var content_data = this.input_content;

        var data = {
            data: content_data,
            block_length: this.slider_value,
            input_format: this.input_format,
            output_format: this.output_format
        };
        console.log("do post:", url);
        //NOTE:use angular post is super slowly.
        $.post(url, data).then(function (response) {
            console.log("received voxelizer_request");
            //console.log("response", response);
            if (response.length > 0) {
                var preview_stl_content = response[0];
                var content = response[1];
                var mesh_content = response[2];
                if (preview_stl_content) {
                    self.preview_stl_content = (preview_stl_content);
                }
                if (content) {
                    self.output_content = (content);
                }
                self.mesh_content = mesh_content;
                if (self.output_format == "stl") {
                    // same as preview_stl_content.
                    self.output_content = this.preview_stl_content;
                }
                if (callback) {
                    callback();
                }
            }

        })
    }
    this.createMesh = function(vertices, indices, normals, colors, world_matrix) {
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
        mesh.scale.x = 1.6 * this.slider_value;
        mesh.scale.y = 1.6 * this.slider_value;
        mesh.scale.z = 1.6 * this.slider_value;
        scene.add(mesh);
        meshes.push(mesh);

        //camera.zoom = 32 * this.slider_value / 64;
        //camera.updateProjectionMatrix();

        return geometry;
    }
    this.voxelizer = function (callback) {
        if (!self.input_content) {
            return
        }
        clearMeshes();
        self.is_loading = true;
        $('#mask').show();
        this.voxelizer_request(function () {
            $('#mask').hide();
                if (self.output_format == "stl") {
                    if(self.preview_stl_content){
                        var loader = new THREE.STLLoader();
                        var geometry = loader.parse(self.preview_stl_content);
                        var material = new THREE.MeshLambertMaterial({ side: THREE.DoubleSide, color: 0xff0000, vertexColors: THREE.VertexColors });
                        var mesh = new THREE.Mesh(geometry, material);

                        mesh.castShadow = true;
                        mesh.receiveShadow = true;

                        scene.add(mesh);
                        meshes.push(mesh);
                    }
                    
                } else if (self.output_format == "bmax") {
                    if (self.mesh_content) {
                        var vertices = self.mesh_content[0];
                        var indices = self.mesh_content[1];
                        var normals = self.mesh_content[2];
                        var colors = self.mesh_content[3];
                        self.createMesh(vertices, indices, normals, colors, null)
                    }
                }
            
            self.is_loading = false;
            if (callback) {
                callback();
            }
        })
    }
    function isSupported(format) {
        if (!format) {
            return false;
        }
        format = format.toLowerCase();
        for (var i = 0; i < supported_extensions.length; i++) {
            if (format == supported_extensions[i]) {
                return true;
            }
        }

    }
    function onWindowResize() {

        var w = container.offsetWidth;
        var h = container.offsetHeight;
        camera.aspect = w / h;
        camera.updateProjectionMatrix();

        renderer.setSize(w, h);

    }
    function animate() {
        requestAnimationFrame(animate);
        axisMonitor.update(controls);
        render();
        controls.update();
        transformControl.update();


    }

    function render() {
        renderer.render(scene, camera);
    }
    function arrayBufferToBase64(buffer) {
        var binary = '';
        var bytes = new Uint8Array(buffer);
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return window.btoa(binary);
    }
    function base64ToArrayBuffer(base64) {
        var binary_string = window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    }
    function removeObject(object) {
        if (object.parent === null) return;
        object.parent.remove(object);
    }
    function clearMeshes() {
        for (var i = 0; i < meshes.length; i++) {
            removeObject(meshes[i]);
        }
        meshes.splice(0, meshes.length);
    }
});
nplcadModule.component("nplcad", {
    templateUrl: "/wp-content/pages/nplcad/templates/nplcadTemplate.html",
    controller: ["$scope", "$http", "$log", "voxelService", NplcadController]
})

function NplcadController($scope, $http, $log, voxelService) {

    var panel = document.getElementById('panel'),
        menu = document.getElementById('menu'),
        showcode = document.getElementById('showcode'),
        view_container = document.getElementById('view_container');
    showcode.addEventListener('click', _toggleCode);
    view_container.addEventListener('dblclick', _toggleCode);
    $scope.csg_node_values = null;

    $('#mask').hide();
    $scope.slider_value = 16;
    
    var input_code = getUrlParameter('code');
    var filename = getUrlParameter('filename');
    input_code = decode_npl(input_code);
    // need to decode
    filename = decode_npl(filename);
    $scope.input_filename = filename;
    function _toggleCode() {
        panel.classList.toggle('viewCode');
    }

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
    _toggleCode()
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
    var controls;
    var meshes = [];
    init();
    animate();

    var axisMonitor;
    function init() {

        container = document.createElement('div');
        container.style["position"] = "relative";
        container.style["width"] = "100%";
        container.style["height"] = "560px";
        $("#view_container").append(container);
        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10000);
        camera.position.set(10, 15, 10);
        camera.lookAt(new THREE.Vector3());
        camera.up.set(0,1,0);
        scene.add(camera);

        // light
        var ambientLight = new THREE.AmbientLight(0x444444);
        ambientLight.name = 'ambientLight';
        scene.add(ambientLight);

        var directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position.x = 17;
        directionalLight.position.y = 30;
        directionalLight.position.z = 9;
        directionalLight.name = 'directionalLight';
        scene.add(directionalLight);

        var helper = new THREE.GridHelper(30, 1);
        helper.material.opacity = 0.25;
        helper.material.transparent = true;
        scene.add(helper);

        axisMonitor = new THREE.AxisMonitor("axis_container");

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
        controls.mouseButtons.ORBIT = THREE.MOUSE.RIGHT;
        controls.mouseButtons.PAN = THREE.MOUSE.LEFT;
        controls.keys.LEFT = 65;
        controls.keys.RIGHT = 68;
        controls.keys.UP = 32;
        controls.keys.BOTTOM = 88;
        controls.keys.FOREWARD = 87;
        controls.keys.BACKWARD = 83;
        controls.addEventListener('change', render);


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
        axisMonitor.update(controls);
        render();
        controls.update();

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
            var sFileName = document.getElementById('filename').value;
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
        geometry.computeVertexNormals()
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
        //console.log("==========color",geometry);
        var facetToStl = function (verts, normal, colors) {
            var faceStl = ''
            faceStl += 'facet normal ' + normal.x + ' ' + normal.y + ' ' + normal.z + '\n'
            faceStl += 'outer loop\n'

            if (!options.isYUp) {

                if (options.colorstl) {
                    faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + ' ' + colors[0].r + ' ' + colors[0].g + ' ' + colors[0].b + '\n'
                    faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + ' ' + colors[1].r + ' ' + colors[1].g + ' ' + colors[1].b + '\n'
                    faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + ' ' + colors[2].r + ' ' + colors[2].g + ' ' + colors[2].b + '\n'
                }else{
                    faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + '\n'
                    faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + '\n'
                    faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + '\n'
                }
            } else {
                if (options.colorstl) {
                    // invert y,z and change the triangle winding
                    faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + ' ' + colors[0].r + ' ' + colors[0].g + ' ' + colors[0].b + '\n'
                    faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + ' ' + colors[2].r + ' ' + colors[2].g + ' ' + colors[2].b + '\n'
                    faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + ' ' + colors[1].r + ' ' + colors[1].g + ' ' + colors[1].b + '\n'
                } else {
                    // invert y,z and change the triangle winding
                    faceStl += 'vertex ' + (verts[0].x + addX) + ' ' + (verts[0].y + addY) + ' ' + (verts[0].z + addZ) + '\n'
                    faceStl += 'vertex ' + (verts[2].x + addX) + ' ' + (verts[2].y + addY) + ' ' + (verts[2].z + addZ) + '\n'
                    faceStl += 'vertex ' + (verts[1].x + addX) + ' ' + (verts[1].y + addY) + ' ' + (verts[1].z + addZ) + '\n'
                }
                
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
                var colors = [
                    geometry.colors[face.a],
                    geometry.colors[face.b],
                    geometry.colors[face.c]
                ]
                stl += facetToStl(verts, face.normal, colors)

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
                var colors = [];
                colors[0] = [
                    geometry.colors[face.a],
                    geometry.colors[face.b],
                    geometry.colors[face.d]
                ]
                colors[1] = [
                    geometry.colors[face.b],
                    geometry.colors[face.c],
                    geometry.colors[face.d]
                ]
                for (var k = 0; k < 2; k++) {
                    stl += facetToStl(verts[k], face.normal, colors[k])
                }

            }
        }
        return stl;
    }
    var code_editor = ace.edit("code_editor");
    code_editor.setTheme("ace/theme/github");
    code_editor.getSession().setMode("ace/mode/lua");
    code_editor.setShowPrintMargin(false);
    code_editor.setOption("maxLines", 40);
    code_editor.setOption("minLines", 5);

    code_editor.commands.addCommand({ name: 'cmdSave', bindKey: { win: 'Ctrl+S' }, exec: function (editor) { $scope.onSaveSource(); }, readOnly: true });
    code_editor.commands.addCommand({ name: 'cmdRun', bindKey: { win: 'F5' }, exec: function (editor) { $scope.onRunCode(); }, readOnly: true });
    
    $scope.isModified = false;
    code_editor.on("input", function () {
        if ($scope.isModified != !code_editor.session.getUndoManager().isClean()) {
            $scope.isModified = !($scope.isModified);
            $scope.$apply();
        }
    });

    code_editor.on("blur", function () {
        controls.enabled = true;
    });
    code_editor.on("focus", function () {
        controls.enabled = false;
    });


    $scope.Examples = [];
    var fetchTimerId = setInterval(function () {
        fetchExamples();
    }, 500)

    function fetchExamples() {
        if ($scope.Examples.length == 0) {
            $('#example').children('div').each(function () {
                $scope.Examples.push({ text: $(this).text(), title: $(this).attr("title") });
            });
        }
        if ($scope.Examples.length > 0) {
            clearInterval(fetchTimerId);
            $scope.$apply();
        }
    }

    $scope.guideLoaded = function () {
        $("div.bhoechie-tab-menu>div.list-group>a").click(function (e) {
            e.preventDefault();
            $(this).siblings('a.active').removeClass("active");
            $(this).addClass("active");
            var index = $(this).index();
            $("div.bhoechie-tab>div.bhoechie-tab-content").removeClass("active");
            $("div.bhoechie-tab>div.bhoechie-tab-content").eq(index).addClass("active");
        });
    }

    //get CSG code examples from nplcadTemplate div and send it to code_editor
    $scope.changeEditorContent = function(index) { 
        var sContent = $scope.Examples[index];
        //alert(sContent);
        if(sContent){
            code_editor.setValue(sContent.text);
            $scope.isModified = true;
        }
        else
            alert("Can't find code example");
    }
		
    var aGeometries = [];
    
    function setStatus(text) {
        $("#logWnd").html(text || "");
    }

    $scope.running = false;
    function onRunCode() {
        if ($scope.running) {
            setStatus("a previous processing request is pending.");
            return;
        }
            
        setStatus("processing ...");
        $scope.running = true;
        aGeometries.splice(0, aGeometries.length);
        var text = code_editor.getValue();
        $http.get("ajax/nplcad?action=runcode&code=" + encodeURIComponent(text)).then(function (response) {
            if (response && response.data && response.data.csg_node_values) {
                //console.log(response.data);
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
                        aGeometries.push(geometry);
                    }
                    setStatus("compile succesfully completed");
                }else{
                    setStatus(response.data.compile_error);
                }
            } else {
                setStatus("compile error");
            }
            $scope.running = false;
        });
    }
    $scope.onRunCode = function () {
        onRunCode();
    }
    $scope.onSaveCode = function(){
        if(aGeometries){
            stlFromGeometries(aGeometries, { download: true });
        }
        else{
            alert("Please compile the code before save.")
        }
    }
    
   
    $scope.onSave = function () {
        voxelService.saveFile();
}
    $scope.sliderOnChange = function (v) {
        $scope.slider_value = v;
        voxelService.setSliderValue(v);
        $scope.$apply();
    }
    $scope.sliderOnInput = function (v) {
        $scope.slider_value = v;
        $scope.$apply();
    }

    ////////////////////
    $scope.currentFilename = null;
    var workspaceDir = nplcadInfo.workspaceDir;
    var req_src = nplcadInfo.req_src;
    if (req_src != "")
        $scope.currentFilename = req_src;

    $scope.getRelativePath = function (filename) {
        filename = filename.replace(/\\/g, "/");
        filename = filename.replace(workspaceDir, "");
        filename = filename.replace(/.*npl_packages\/[^\/]+\//g, "");
        return filename;
    }
    $scope.onSaveSource = function () {
        var editor = ace.edit("code_editor");
        var filename = $scope.currentFilename;
        var content = editor.session.getValue();
        if (!filename) {
            return
        }
        var url = "ajax/nplcad?action=nplcad_savefile";
        var data = {
            content: content,
            filename: filename
        };
        $.post(url, data).then(function (response) {
            if (response && response[0]) {
                $scope.isModified = false;
                $scope.$apply();
                $.notify("source file is saved to: " + filename, { type: "success" });
                // run code immediately after save
                $scope.onRunCode();
            }
            console.log(response);
        })
    }
    $scope.openFile = function (filename, bForceReopen,callback) {
        filename = $scope.getRelativePath(filename);
        var editor = ace.edit("code_editor");
        if ($scope.currentFilename != filename || bForceReopen) {
           
            $http.get("ajax/viewsource?action=get_source&src=" + encodeURIComponent(filename)).then(function (response) {
                var text = response.data.text || "";
                if (text == "") {
                    text = $("#empty_script_template").html();
                }

                editor.session.setValue(text);
                var ext = filename.split('.').pop();
                if (ext == "xml" || ext == "html")
                    editor.session.setMode("ace/mode/xml");
                else
                    editor.session.setMode("ace/mode/lua");
                $scope.currentFilename = filename;
                $scope.openFilename = filename;
                $scope.isModified = false;
                editor.session.getUndoManager().markClean();
                callback();
            });
        }
    }
    function directlyRunCode() {

        if ($scope.currentFilename) {
            $scope.openFile($scope.currentFilename, true, function () {
                onRunCode();
            });
        }


        $('.modal').on('shown.bs.modal', function () {      //correct here use 'shown.bs.modal' event which comes in bootstrap3

            voxelService.init();
            var content = stlFromGeometries(aGeometries, { colorstl: true });
            // content = window.btoa(content);

            voxelService.show($scope.currentFilename, "colorstl", content, "bmax");

        })
    }
    directlyRunCode();
}

nplcadModule.component("example",{
	templateUrl: "/wp-content/pages/nplcad/templates/example.html"
})













