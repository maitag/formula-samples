package;

import js.Browser;
import js.html.Float32Array;
import js.html.CanvasElement;
import js.html.InputElement;
import js.html.webgl.Program;
import js.html.webgl.RenderingContext;
import js.html.webgl.GL;
import js.html.webgl.Shader;

import Formula;

/**
 * simple webgl starter for Formula
 * by Sylvio Sell, Rostock 2017
 * 
 **/


class Main 
{
	static var canvas:CanvasElement;
	static var input:InputElement;
	static var width:Int;
	static var height:Int;
	static var gl:RenderingContext;
	
	static var formula:Formula = "x^2 + y^2";
	
	static function main()
	{
		width = Browser.window.innerWidth;
		height = Browser.window.innerHeight;
		canvas = Browser.document.createCanvasElement();
		canvas.width = width;
		canvas.height = height;
		canvas.style.position = "absolute";
		canvas.style.top = "0px";
		canvas.style.left = "0px";
		canvas.style.zIndex = "-1024";
		Browser.document.body.appendChild(canvas);
		
		try {
			gl = canvas.getContext("experimental-webgl");
			if (gl == null) { throw "x"; }
		} catch (err:Dynamic) {
			throw "Your web browser does not support WebGL!";
		}

		input = Browser.document.createInputElement();
		input.value = formula;
		Browser.document.body.appendChild(input);
		input.onchange = function(event) {
            updateFormula(input.value);
        }
		
		//Browser.window.setTimeout(draw, 500);
		draw();
	}
	
	static public function updateFormula (_formula:String):Void
	{
		if (_formula != null && _formula != '')
		{
			try {
				var f:Formula = new Formula(_formula);
				var p:Array<String> = f.params();
				if ((p.indexOf("x") >-1) && (p.indexOf("y") >-1) ) {
					formula = f;
					input.style.backgroundColor = "#ffffff";
					draw();
				} else {
					trace('Error: wrong params, need x and y');
					input.style.backgroundColor = "#ffddcc";
				}
			}
			catch (msg:String)
			{
				trace('Error: $msg');
				input.style.backgroundColor = "#ffddcc";
			}
		}
	}

	static function draw()
	{
		gl.clearColor(0.0, 0.0, 0.0, 1);
		gl.clear(GL.COLOR_BUFFER_BIT);

		var prog:Program = shaderProgram(gl,
			'
				attribute vec2 pos;
				varying vec2 vTexCoord;
				void main() {
					vTexCoord = pos;
					gl_Position = vec4(pos, 0.0, 1.0);
				}
			',
			'
				precision highp float;
				varying vec2 vTexCoord;
				void main() {
					float x = vTexCoord.x;
					float y = vTexCoord.y;
					/*
					if ( y > sin(x*2.0*3.14) ) {
						gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
					}
					*/
					if ( ${formula.toString('glsl')} < 1.0 ) {
						gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
					}
					else {
						gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
					}
				}
			'
		);
		gl.useProgram(prog);

		attributeSetFloats(gl, prog, "pos", 2, new Float32Array([
			-1,  1,
			-1, -1,
			1, 1,
			1, -1
		]));
		
		gl.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
	}
	
	static function shaderProgram(gl:RenderingContext, vs:String, fs:String):Program
	{
		var prog = gl.createProgram();
		var addshader = function(type:Int, source:String) {
			var shader:Shader = gl.createShader(type);
			gl.shaderSource(shader, source);
			gl.compileShader(shader);
			if (!gl.getShaderParameter(shader, GL.COMPILE_STATUS)) {
				throw "Could not compile shader:\n\n"+gl.getShaderInfoLog(shader);
			}
			gl.attachShader(prog, shader);
		};
		addshader(GL.VERTEX_SHADER, vs);
		addshader(GL.FRAGMENT_SHADER, fs);
		gl.linkProgram(prog);
		if (!gl.getProgramParameter(prog, GL.LINK_STATUS)) {
			throw "Could not link the shader program!";
		}
		return prog;
	}

	static function attributeSetFloats(gl:RenderingContext, prog:Program, attr_name:String, rsize:Int, arr:Float32Array) {
		gl.bindBuffer(GL.ARRAY_BUFFER, gl.createBuffer());
		gl.bufferData(GL.ARRAY_BUFFER, arr, GL.STATIC_DRAW);
		var attr:Int = gl.getAttribLocation(prog, attr_name);
		gl.enableVertexAttribArray(attr);
		gl.vertexAttribPointer(attr, rsize, GL.FLOAT, false, 0, 0);
	}
		

}
