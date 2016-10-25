

THREE.GridHelperZup = function (size, divisions, color1, color2) {

    divisions = divisions || 1;
    color1 = new THREE.Color(color1 !== undefined ? color1 : 0x444444);
    color2 = new THREE.Color(color2 !== undefined ? color2 : 0x888888);

    var center = divisions / 2;
    var step = (size * 2) / divisions;
    var vertices = [], colors = [];

    for (var i = 0, j = 0, k = -size; i <= divisions; i++, k += step) {

        //vertices.push(-size, 0, k, size, 0, k);
        //vertices.push(k, 0, -size, k, 0, size);

        vertices.push(-size, k, 0, size, k, 0);
        vertices.push(k, -size, 0, k, size, 0);

        var color = i === center ? color1 : color2;

        color.toArray(colors, j); j += 3;
        color.toArray(colors, j); j += 3;
        color.toArray(colors, j); j += 3;
        color.toArray(colors, j); j += 3;

    }

    var geometry = new THREE.BufferGeometry();
    geometry.addAttribute('position', new THREE.Float32Attribute(vertices, 3));
    geometry.addAttribute('color', new THREE.Float32Attribute(colors, 3));

    var material = new THREE.LineBasicMaterial({ vertexColors: THREE.VertexColors });

    THREE.LineSegments.call(this, geometry, material);

};

THREE.GridHelperZup.prototype = Object.create(THREE.LineSegments.prototype);
THREE.GridHelperZup.prototype.constructor = THREE.GridHelperZup;

THREE.GridHelperZup.prototype.setColors = function () {

    console.error('THREE.GridHelper: setColors() has been deprecated, pass them in the constructor instead.');

};
