angular.module('NPLCAD_App', ['ngStorage'])
.controller('nplcadController', function ($scope, $http) {
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
    }
    var code_editor = ace.edit("code_editor");
    code_editor.setTheme("ace/theme/github");
    code_editor.getSession().setMode("ace/mode/lua");
    code_editor.setShowPrintMargin(false);

    $scope.onRunCode = function () {
        $("#logWnd").html("");
        var text = code_editor.getValue();
        $http.get("ajax/nplcad?action=runcode&code=" + encodeURIComponent(text)).then(function (response) {
            if (response && response.data && response.data.result) {
                if (response.data.success) {
                    var vertices = response.data.result[0];
                    var indices = response.data.result[1];
                    var normals = response.data.result[2];
                    var colors = response.data.result[3];

                    createMesh(vertices, indices, normals, colors);

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