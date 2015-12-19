precision highp float;

uniform mat3 matrix3;
uniform vec4 value4;

attribute vec2 position2;
attribute vec4 position4;
attribute vec4 coord4;

varying vec2 _coord2;
varying vec4 _coord4;

export void smoothPathVertex() {
	_coord2 = position4.zw;
	_coord4 = coord4;
	gl_Position = vec4(matrix3 * vec3(position4.xy, 1.0), 0.0).xywz;
}

export void smoothPathFragment() {
	gl_FragColor = _coord4 * min(1.0, min(_coord2.x, _coord2.y));
}

export void stencilVertex() {
	_coord2 = position4.zw;
	gl_Position = vec4(matrix3 * vec3(position4.xy, 1.0), 0.0).xywz;
}

export void stencilFragment() {
	if (_coord2.x * _coord2.x - _coord2.y > 0.0) {
		discard;
	}
	gl_FragColor = vec4(0.0);
}

export void coverVertex() {
	gl_Position = vec4(matrix3 * vec3(position2.xy, 1.0), 0.0).xywz;
}

export void coverFragment() {
	gl_FragColor = value4;
}

export void demoVertex() {
	gl_Position = vec4(position2, 0.0, 1.0);
}

export void demoFragment() {
	vec2 pixel = gl_FragCoord.xy;
	float x = (pixel.x - value4.x) / value4.z;
	float y = (value4.w - pixel.y - value4.y) / value4.z;

	float r = sqrt(x * x + y * y);
	float theta = atan(y, x);

	// float z = cos(x - sin(y)) - cos(y + sin(x));
	// float z = y - (x * x * x * 0.002 - sin(x));
	// float z = y - (sin(x) + tan(x * 0.2));
	// float z = sin(theta * 7.0) - sin(r);
	float z = sin(r + theta);

	/*
	float z = 0.0;
	for (int i = 1; i < 4; i++)
		z +=
			cos(x * 4.0 / float(i)) +
			sin(y * 4.0 / float(i)) +
			sin(r * 4.0 / float(i));
	*/

	float slopeX = dFdx(z);
	float slopeY = dFdy(z);
	float slope = sqrt(slopeX * slopeX + slopeY * slopeY);
	float edge = clamp(2.0 - abs(z) / slope, 0.0, 1.0);
	float area = clamp(0.5 + z / slope, 0.0, 1.0);

	float alpha = mix(edge, 1.0, area * 0.25);
	// float alpha = edge;

	gl_FragColor = vec4(0.0, 0.5, 1.0, 1.0) * alpha;
}
