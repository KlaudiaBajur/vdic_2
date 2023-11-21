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


class points_c;
		real x;
		real y;
		
	function new(real x_r, real y_r);
		x = x_r;
		y = y_r;
	endfunction
	
	function string to_string();
		string point_str;
		point_str = $sformatf("(%0.2f, %0.2f)", x, y);
		return point_str;
	endfunction
endclass: points_c


virtual class shape_c;
	string name;
	protected points_c points[$];

	function new(string name_kb, points_c points_p[$]);
		name = name_kb;
		points = points_p;
	endfunction
	
	pure virtual function real get_area();

	function void print();
		$display("This is: %0s ", name);
		foreach(points[i])
			$display("(%0s)", points[i].to_string());
		if (get_area() == -1) begin
			$display("Area is: can not be calculated for generic %s.", name);
		end
		else begin
			$display("Area is %0.2f ", get_area());
		end
	endfunction : print

endclass: shape_c




class polygon_c extends shape_c;
	
	function new(string name, points_c points[$]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		 return -1;
	endfunction: get_area
endclass: polygon_c


class rectangle_c extends shape_c;
	function new(string name,points_c points[4]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 4;
		return area;
	endfunction: get_area
endclass: rectangle_c



class triangle_c extends shape_c;
	
	function new(string name,points_c points[3]);
		super.new(name, points);
	endfunction
	
	function real get_area();
		real area = 3;
		return area;
	endfunction: get_area
	
endclass: triangle_c


class circle_c extends shape_c;
	function new(string name,points_c points[2]);
		super.new(name, points);
	endfunction
	
	function real get_radius();
		real radius = $pow((points[1].x-points[0].x), 2) + $pow((points[1].y-points[0].y), 2);
		return radius;
	endfunction: get_radius
	
	
	function real get_area();
		real radius = get_radius();
		real area =  3.14*radius;
		return area;
	endfunction: get_area
	
	function void print();
		$display("This is: %0s ", name);
		$display("%0s", points[0].to_string());		// circle center
		$display("radius: %0.2f", $sqrt(get_radius()));
		$display("Area is: %0.2f ", get_area());
	endfunction : print
endclass: circle_c



class shape_reporter #(type T = shape_c);
	protected static T storage[$];
	//int size = $size.storage;
	
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
	
	static function shape_c make_shape(points_c points[$]);
		polygon_c polygon;
		rectangle_c rectangle;
		triangle_c triangle;
		circle_c circle;
		
		//$display("size $d", $size(points));
		case(points.size())
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
		points_c points[$];
		points_c point;
		int file;
		real points_table[7][0:1];
		int i;
		string line;
		int code;
		int table_length;
		int s_ret;
		byte last_char;
		real x;
		real y;

		
		file = $fopen("../tb/lab04part1_shapes.txt", "r");
		if(file == 0) begin
			$display("Error. Could not open a file.");
			$stop;
		end
		else begin 
			/*
			while($fgets(line, file)) begin
				//$display(line);
		    	code = $sscanf(line, "%0.2f %0.2f \
									%0.2f %0.2f \
									%0.2f %0.2f \
									%0.2f %0.2f \
									%0.2f %0.2f \
									%0.2f %0.2f \
									%0.2f %0.2f", 
									
									points_table[0][0], points_table[0][1],
									points_table[1][0], points_table[1][1],
									points_table[2][0], points_table[2][1],
									points_table[3][0], points_table[3][1],
									points_table[4][0], points_table[4][1],
									points_table[5][0], points_table[5][1],
									points_table[6][0], points_table[6][1]);
			    
			    //$display(code);
			    table_length = ((code/2)-1);
				for(i = 0; i <= (code/2)-1; i++) begin
					points[i][0] = points_table[i][0];
					points[i][1] = points_table[i][1];
				end
				$display("Code: $d", code);
		    	$display("Table length: $d", table_length);
				shape = shape_factory_c::make_shape(points);
			end	
			shape_reporter#(circle_c)::report_shapes();
			shape_reporter#(triangle_c)::report_shapes();
			shape_reporter#(rectangle_c)::report_shapes();
			shape_reporter#(polygon_c)::report_shapes();
		 */
		 
			while (!$feof(file)) begin						// do while until end of file
				s_ret = $fscanf(file, "%f %f%c", x, y, last_char);
				point = new(x, y);							// make pair of 2 real numbers (x and y) - point
				points.push_back(point);					// push points to point_c points
			
				if(last_char == "\n") begin					// if end of line in .txt - make shape
					shape = shape_factory_c::make_shape(points);
					points.delete();						// clear queue
				end
			end
			$fclose(file);
			shape_reporter#(circle_c)::report_shapes();
			shape_reporter#(triangle_c)::report_shapes();
			shape_reporter#(rectangle_c)::report_shapes();
			shape_reporter#(polygon_c)::report_shapes();
		end
		
		
	end

	
endmodule: top
