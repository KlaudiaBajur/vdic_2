/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

virtual class shape_c;
	string name;
	real points[$][0:1];

	function new(string name_kb, real points_kb[$][0:1]);
		name = name_kb;
		points = points_kb;
	endfunction
	
	pure virtual function real get_area();

	function void print();
		$display("This is: %0s ", name);
		foreach(points[i])
			$display("(%0f, %0f)", points[i][0], points[i][1]);
		$display("Area is %0.2f ", get_area());
	endfunction : print

endclass: shape_c


class polygon_c extends shape_c;
	function new(string name,real points[$][0:1]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 5;
		return area;
	endfunction: get_area
endclass: polygon_c

class rectangle_c extends shape_c;
	function new(string name,real points[3][0:1]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 4;
		return area;
	endfunction: get_area
endclass: rectangle_c


class triangle_c extends shape_c;
	
	function new(string name,real points[2][0:1]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 3;
		return area;
	endfunction: get_area
	
endclass: triangle_c


class circle_c extends shape_c;
	function new(string name,real points[1][0:1]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 2;
		return area;
	endfunction: get_area
endclass: circle_c



class shape_reporter #(type T = shape_c);
	protected static T storage[$];
	
	static function void storage_shapes(T shape_c);
		storage.push_back(shape_c);
	endfunction: storage_shapes
	
	static function void report_shapes();
		foreach (storage[i])begin
			storage[i].print();
		end

	endfunction
endclass: shape_reporter



class shape_factory_c;
	
	static function shape_c make_shape(real points[$][0:1]);
		polygon_c polygon;
		rectangle_c rectangle;
		triangle_c triangle;
		circle_c circle;
		
		case($size(points))
			2 : begin	
					circle = new("circle", points);
					shape_reporter#(circle_c)::storage_shapes(circle);
					return circle;
				end
			3 : begin
					triangle = new("triangle", points);
					shape_reporter#(triangle_c)::storage_shapes(triangle);
					return triangle;
					
				end
			4 : begin
					rectangle = new("rectangle", points);
					shape_reporter#(rectangle_c)::storage_shapes(rectangle);
					return rectangle;
					
				end
			default: begin
					polygon = new("polygon", points);
					shape_reporter#(polygon_c)::storage_shapes(polygon);
					return polygon;
					
				end
		endcase
				
	endfunction: make_shape
	
endclass: shape_factory_c



module top;
	shape_c shape;
	
	initial begin
		//shape_c shape;
		real points[$][0:1];
		real point[20][0:1];
		real x;
		real y;
		int file;
		int file_handle;
		int i;
		int k;
		string line;
		int count;
		int ik;
		int wiersz;
		
		file = $fopen("../tb/lab04part1_shapes.txt", "r");
		if(file == 0) begin
			$display("Error. Could not open a file.");
			$stop;
		end
		i = 0;
		while(!$feof(file)) begin
			$fscanf(file, "%f %f", x, y);
			points[i][0] = x;
      		points[i][1] = y;
			$display("Point[%0d]: (%0f, %0f)", i, points[i][0], points[i][1]);
			i++;
		end
		
		file_handle = $fopen("../tb/lab04part1_shapes.txt", "r");
      	$fgets(line, file_handle);
	    
      	$display("Line read: %s", line);
		
		while(!$feof(file_handle)) begin
			for(i=0; i< line; i++) begin
				$fscanf(line, "%f %f", x, y);
				point[i][0] = x;
      			point[i][1] = y;
				$display("2 Point[%0d]: (%0f, %0f)", i, point[i][0], point[i][1]);
			end
		
    	end
		

		shape = shape_factory_c::make_shape(points);
		shape_reporter#(rectangle_c)::report_shapes();
		shape_reporter#(circle_c)::report_shapes();
		shape_reporter#(triangle_c)::report_shapes();
		shape_reporter#(polygon_c)::report_shapes();
		$fclose(file);
	end

	
endmodule: top
