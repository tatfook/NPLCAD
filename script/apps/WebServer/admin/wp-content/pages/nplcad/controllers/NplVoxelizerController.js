var nplvoxelizer = angular.module('NPLCAD_App', ['ui.bootstrap', "rzModule"]);
nplvoxelizer.component("nplvoxelizer", {
    templateUrl: "/wp-content/pages/nplcad/templates/NplVoxelizerTemplate.html",
    controller: function ($scope, $http, $log) {

        if (Page)
            Page.ShowSideBar(false);
        $('#mask').hide();
        var view_container = document.getElementById('voxel_view_container');
        var container, stats;
        var camera, scene, renderer;
        var controls, transformControl;
        var meshes = [];
        var supported_extensions = ["stl", "bmax"];

        var input_file_name = getUrlParameter('input_file_name');
        var input_format = getUrlParameter('input_format');
        var input_content = getUrlParameter('input_content');
        var output_format = getUrlParameter('output_format');
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
        init_threejs();
        animate();
        function init_threejs() {
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
            var ambientLight = new THREE.AmbientLight(0x444444);
            ambientLight.name = 'ambientLight';
            scene.add(ambientLight);

            var directionalLight = new THREE.DirectionalLight(0xffffff, 1);
            directionalLight.position.x = 17;
            directionalLight.position.y = 9;
            directionalLight.position.z = 30;
            directionalLight.name = 'directionalLight';
            scene.add(directionalLight);

            //scene.add(new THREE.HemisphereLight(0x443333, 0x111122));
            //addShadowedLight(1, 1, 1, 0xffffff, 1.35);
            //addShadowedLight(0.5, 1, -1, 0xffaa00, 1);

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
        function addShadowedLight(x, y, z, color, intensity) {

            var directionalLight = new THREE.DirectionalLight(color, intensity);
            directionalLight.position.set(x, y, z);
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

        $scope.input_content = "";
        $scope.input_format = "stl";
        $scope.output_format = "stl";
        $scope.preview_stl_content = null;
        $scope.output_content = null;
        $scope.input_file_name = "";
        $scope.is_loading = false;
        $scope.slider = {
            value: 16,
            options: {
                floor: 1,
                ceil: 64,
                step: 1
            }
        };
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
        function get_filename_ext(fileName) {
            var name = fileName.substr(0, fileName.lastIndexOf('.'));
            var ext = fileName.substr(fileName.lastIndexOf('.') + 1);
            return [name,ext];
        }
        $scope.uploadFile = function (files) {
            $scope.input_content = null;
            $scope.preview_stl_content = null;
            $scope.output_content = null;
            clearMeshes();

            if (files.length == 0) {
                return;
            }
            var file = files[0];
            $scope.input_file_name = file.name;
            var arr = get_filename_ext(file.name);
            // get input format
            $scope.input_format = arr[1];

            var reader = new FileReader();
            reader.onload = function () {
                var arrayBuffer = reader.result;
                $scope.input_content = arrayBufferToBase64(arrayBuffer)
                voxelizer();
            };
            reader.readAsArrayBuffer(files[0]);
            $scope.$apply();
        }
        function voxelizer_request(callback) {
            var url = "ajax/nplvoxelizer?action=nplvoxelizer_voxelizer";
            console.log("voxelizer request data length:", $scope.input_content.length, "block_length:", $scope.slider.value, "input_format:", $scope.input_format, "output_format:", $scope.output_format);
            var content_data = $scope.input_content;
            var data =  {
                data: content_data,
                block_length: $scope.slider.value,
                input_format: $scope.input_format,
                output_format: $scope.output_format
            };
            console.log("do post:", url);
            //NOTE:use angular post is super slowly.
            $.post(url, data).then(function (response) {
                console.log("received voxelizer_request");
                //console.log("response", response);
                if (response.length > 0) {
                    var preview_stl_content = response[0];
                    var content = response[1];
                    if (preview_stl_content) {
                        $scope.preview_stl_content = window.atob(preview_stl_content);
                    }
                    if (content) {
                        $scope.output_content = window.atob(content);
                    }
                    if ($scope.output_format == "stl") {
                        // same as preview_stl_content.
                        $scope.output_content = $scope.preview_stl_content;
                    }
                    if (callback) {
                        callback();
                    }
                }
                
            })
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
        function voxelizer(callback) {
            if (!$scope.input_content) {
                return
            }
            $scope.is_loading = true;
            $('#mask').show();
            voxelizer_request(function () {
                $('#mask').hide();
                clearMeshes();
                var loader = new THREE.STLLoader();
                var geometry = loader.parse($scope.preview_stl_content);
                //var material = new THREE.MeshPhongMaterial({ color: 0x0000ff, specular: 0x111111, shininess: 200 });
                //var material = new THREE.MeshBasicMaterial({ color: 0xff0000, vertexColors: THREE.VertexColors });
                var material = new THREE.MeshLambertMaterial({ side: THREE.DoubleSide, color: 0x0000ff, vertexColors: THREE.VertexColors });
                var mesh = new THREE.Mesh(geometry, material);

                mesh.castShadow = true;
                mesh.receiveShadow = true;

                scene.add(mesh);
                meshes.push(mesh);
                $scope.is_loading = false;
                if (callback) {
                    callback();
                }
            })
        }
        function saveFile(fileName,output_format) {
            var arr = get_filename_ext(fileName);
            var name = arr[0];
            var ext = arr[1];

            if (output_format == ext) {
                name = name + ".voxel." + output_format;
            } else {
                name = name + "." + output_format;
            }
            console.log("onSave:", name);
            if ($scope.output_content) {
                var blob = new Blob([$scope.output_content], { type: 'text/plain' });
                saveAs(blob, name);
            }
        }

        $("#myButtons :input").change(function () {
            var id = ($(this).attr('id'));
            $scope.onSelected(id);
        });

        $scope.onSelected = function (format) {
            if (!isSupported(format)) {
                console.log("unsupported format:",format);
            }
            if (!$scope.input_file_name) {
                return
            }
            $scope.output_format = format;
            voxelizer();
        }
        $scope.onSave = function () {
            if ($scope.input_file_name && $scope.output_format) {
                saveFile($scope.input_file_name, $scope.output_format);
            }
        }
        $scope.$on("slideEnded", function () {
            if (!$scope.is_loading) {
                $scope.preview_stl_content = null;
                $scope.output_content = null;
                clearMeshes();
                voxelizer()
            }
        });
        function init() {

            //if (output_format) {
            //    $scope.output_format = output_format;
            //}
            //if (input_content) {
            //    $scope.input_content = input_content;
            //}
            //if (input_file_name) {
            //    $scope.input_file_name = input_file_name;
            //}
            //if (input_format) {
            //    $scope.input_format = input_format;
            //}
            //for (var i = 0; i < supported_extensions.length; i++) {
            //    if (supported_extensions[i] == $scope.output_format) {
            //        var name = $scope.output_format;
            //        var btn = $("#" + name);
            //        if (btn) {
            //            btn.click();
            //        }
            //    }
            //}
            console.log("=====================");
        }
        init();
    }
})













