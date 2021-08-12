
module Ship_Control(
	input logic				Clk,frame_clk, Reset, up, down, left, right, Restart, shoot, ShipReset, Ship_Collision, SW,
	input logic [9:0]		DrawX, DrawY,
	input logic [14:0]	Rocket_Collision,
	output logic			is_Ship, Ship_in,
	output logic [14:0]	is_Rocket,
	output logic [9:0]	Ship_DistX, Ship_DistY, Rock_DistX, Rock_DistY
);

	logic [9:0] ShipXsig, ShipYsig;
	
	 ShipMovement Move(
			.Clk,
			.Reset(Reset),
			.frame_clk(frame_clk),
			.up(up),
			.down(down),
			.left(left),
			.right(right),
			.Restart(Restart),
			.SW,
			.ShipReset,
			.Ship_Collision,
			.DrawX(DrawX),
			.DrawY(DrawY),
			.is_Ship(is_Ship),
			.Ship_in(Ship_in),
			.Ship_DistX(Ship_DistX),
			.Ship_DistY(Ship_DistY),
			.ShipX(ShipXsig),
			.ShipY(ShipYsig)
		);
		
		Rocket_Control RocketCont(
			.Reset(Reset | ShipReset),
			.frame_clk(frame_clk),
			.shoot(shoot & Ship_in),
			.DrawX(DrawX),
			.DrawY(DrawY),
			.ShipX(ShipXsig),
			.ShipY(ShipYsig),
			.is_Rocket(is_Rocket),
			.Rock_DistX(Rock_DistX),
			.Rock_DistY(Rock_DistY),
			.Rocket_Collision
		);

		

endmodule
		
		
module  ShipMovement ( input         Clk, SW,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input 		  up, down, left, right, Restart, ShipReset, Ship_Collision,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_Ship, Ship_in,             // Whether current pixel belongs to Ship or background
					output logic [9:0]	Ship_DistX, Ship_DistY, ShipX, ShipY
              );
    
    parameter [9:0] Ship_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ship_Y_Center = 10'd440;  // Center position on the Y axis
    parameter [9:0] Ship_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ship_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ship_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ship_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ship_X_Step = 10'd3;      // Step size on the X axis
    parameter [9:0] Ship_Y_Step = 10'd3;      // Step size on the Y axis
    parameter Ship_XSize = 10'd17;
    parameter Ship_YSize = 10'd19;
    parameter [9:0] Ship_X_Center2 = 10'd270;  // Center position on the X axis
    
    logic [9:0] Ship_X_Pos, Ship_X_Motion, Ship_Y_Pos, Ship_Y_Motion;
    logic [9:0] Ship_X_Pos_in, Ship_X_Motion_in, Ship_Y_Pos_in, Ship_Y_Motion_in;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
				if(SW == 1'b1)
				begin
					Ship_X_Pos <= Ship_X_Center2;
					Ship_Y_Pos <= Ship_Y_Center;
					Ship_X_Motion <= 10'd0;
					Ship_Y_Motion <= 10'd0;
				end
				else
				begin
					Ship_X_Pos <= Ship_X_Center;
					Ship_Y_Pos <= Ship_Y_Center;
					Ship_X_Motion <= 10'd0;
					Ship_Y_Motion <= 10'd0;
				end
        end
        if (ShipReset)
				if(SW == 1'b1)
				begin
					Ship_X_Pos <= Ship_X_Center2;
					Ship_Y_Pos <= Ship_Y_Center;
					Ship_X_Motion <= 10'd0;
					Ship_Y_Motion <= 10'd0;
				end
				else
				begin
					Ship_X_Pos <= Ship_X_Center;
					Ship_Y_Pos <= Ship_Y_Center;
					Ship_X_Motion <= 10'd0;
					Ship_Y_Motion <= 10'd0;
				end
        else
        begin
            Ship_X_Pos <= Ship_X_Pos_in;
            Ship_Y_Pos <= Ship_Y_Pos_in;
            Ship_X_Motion <= Ship_X_Motion_in;
            Ship_Y_Motion <= Ship_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ship_X_Pos_in = Ship_X_Pos;
        Ship_Y_Pos_in = Ship_Y_Pos;
        Ship_X_Motion_in = Ship_X_Motion;
        Ship_Y_Motion_in = Ship_Y_Motion;
        
         // Update position and motion only at rising edge of frame clock 
        if (frame_clk_rising_edge)
        begin
		  				// Update the Ship's position with its motion
				Ship_X_Pos_in = Ship_X_Pos + Ship_X_Motion;
				Ship_Y_Pos_in = Ship_Y_Pos + Ship_Y_Motion;
				
				if (Restart == 1'b1)
				begin
					Ship_X_Pos_in = Ship_X_Center;
					Ship_Y_Pos_in = Ship_Y_Center;
					Ship_X_Motion_in = 0;
					Ship_Y_Motion_in = 0;
				end
				else if((up == 1'b1) && (left == 1'b1))
				begin
					Ship_X_Motion_in = ~(Ship_X_Step) + 1'b1;
					Ship_Y_Motion_in = ~(Ship_Y_Step) + 1'b1;
				end
				else if((up == 1'b1) && (right == 1'b1))
				begin
					Ship_X_Motion_in = Ship_X_Step;
					Ship_Y_Motion_in = ~(Ship_Y_Step) + 1'b1;
				end
				else if((down == 1'b1) && (right == 1'b1))
				begin
					Ship_X_Motion_in = Ship_X_Step;
					Ship_Y_Motion_in = Ship_Y_Step;
				end
				else if((down == 1'b1) && (left == 1'b1))
				begin
					Ship_X_Motion_in = ~(Ship_X_Step) + 1'b1;
					Ship_Y_Motion_in = Ship_Y_Step;
				end
				else if(up == 1'b1)
				begin
					Ship_X_Motion_in = 10'd0;
					Ship_Y_Motion_in = ~(Ship_Y_Step) + 1'b1;
				end
				else if(down == 1'b1)
				begin
					Ship_X_Motion_in = 10'd0;
					Ship_Y_Motion_in = Ship_Y_Step;
				end
				else if(left == 1'b1)
				begin
					Ship_X_Motion_in = ~(Ship_X_Step) + 1'b1;
					Ship_Y_Motion_in = 10'd0;
				end
				else if(right == 1'b1)
				begin
					Ship_X_Motion_in = Ship_X_Step;
					Ship_Y_Motion_in = 10'd0;
				end
				else
				begin
					Ship_X_Pos_in = Ship_X_Pos;
					Ship_Y_Pos_in = Ship_Y_Pos;
				end
				
				// Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ship_Y_Pos - Ship_Size <= Ship_Y_Min 
            // If Ship_Y_Pos is 0, then Ship_Y_Pos - Ship_Size will not be -4, but rather a large positive number.
            if( Ship_Y_Pos + Ship_XSize >= Ship_Y_Max )  // Ship is at the bottom edge, BOUNCE!
				begin
					 Ship_X_Motion_in = 0;
                Ship_Y_Motion_in = (~(Ship_Y_Step) + 1'b1);  // 2's complement.  
            end else if ( Ship_Y_Pos <= Ship_Y_Min + Ship_YSize )  // Ship is at the top edge, BOUNCE!
				begin
					 Ship_X_Motion_in = 0;
                Ship_Y_Motion_in = Ship_Y_Step;
            // TODO: Add other boundary detections and handle keypress here.
				end
				if( Ship_X_Pos >= ((Ship_X_Max) - Ship_XSize ))					// Ship is at the right edge. BOUNCE!
				begin
					 Ship_Y_Motion_in = 0;
					 Ship_X_Motion_in = (~(Ship_Y_Step) + 1'b1);	// 2's complement
				end else if ( Ship_X_Pos <= Ship_X_Min + Ship_XSize)	// Ship is at the left edge. BOUNCE!
				begin
					 Ship_Y_Motion_in = 0;
					 Ship_X_Motion_in = Ship_X_Step;
				end 
				
        end
        
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ship_Y_Pos is updated using Ship_Y_Motion. 
              Will the new value of Ship_Y_Motion be used when Ship_Y_Pos is updated, or the old? 
              What is the difference between writing
                "Ship_Y_Pos_in = Ship_Y_Pos + Ship_Y_Motion;" and 
                "Ship_Y_Pos_in = Ship_Y_Pos + Ship_Y_Motion_in;"?
              How will this impact behavior of the Ship during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end
    
    // Compute whether the pixel corresponds to Ship or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    logic [3:0] Lives;
    initial begin
        Lives = 4'd9;
		end
		  
	always_ff @ (posedge Reset or posedge frame_clk )
	begin
		if(Reset)
			Lives <= 4'd9;
		else if(ShipReset)
			Lives <= 4'd9;
		else if (Ship_Collision == 1'b1)
			Lives <= Lives - 1'b1;
		else
			Lives <= Lives;
	end

    always_comb begin
			Ship_in = Lives > 4'd0;
        if ( (DrawX >= ShipX && DrawX <= ShipX + Ship_XSize && DrawY >= ShipY && DrawY <= ShipY + Ship_YSize) && (Ship_in == 1'b1)) 
			begin
				is_Ship = ~Ship_Collision;
				Ship_DistX = DrawX - Ship_X_Pos;
				Ship_DistY = DrawY - Ship_Y_Pos;
			end
        else
			begin
            is_Ship = 1'b0;
				Ship_DistX = 10'd0;
				Ship_DistY = 10'd0;
			end
        /* The Ship's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
    assign ShipX = Ship_X_Pos;
	 assign ShipY = Ship_Y_Pos;
	 
endmodule



