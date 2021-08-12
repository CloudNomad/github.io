module Rocket_Control(
	input logic 			Reset, frame_clk, shoot,
	input logic [9:0]		DrawX, DrawY, ShipX, ShipY,
	input logic [14:0]	Rocket_Collision,
	output logic [14:0]	is_Rocket,
	output logic [9:0]	Rock_DistX, Rock_DistY
);

	logic [14:0] EnableRock, ShootRocket, is_Rocketsig;

	Rocket_Follow follower(
		.Reset(Reset),
		.frame_clk(frame_clk),
		.shoot(shoot),
		.EnableRock(EnableRock),
		.ShootRocket(ShootRocket)
	);
		
	logic [9:0] GunXoffset = 7;
	logic [9:0] GunYoffset = 0;
	logic [9:0] Rock_DistXsig [14:0];
	logic [9:0] Rock_DistYsig [14:0];
	
	Rocket rockets [14:0](
		.Reset(Reset),
		.frame_clk(frame_clk),
		.ShootRocket(ShootRocket),
		.DrawX(DrawX),
		.DrawY(DrawY),
		.SGunX(ShipX+GunXoffset),
		.SGunY(ShipY+GunYoffset),
		.Rock_DistX(Rock_DistXsig),
		.Rock_DistY(Rock_DistYsig),
		.EnableRock(EnableRock),
		.is_Rocket(is_Rocketsig),
		.Rocket_Collision
	);
	
	always_comb
	begin
		is_Rocket = is_Rocketsig;
		Rock_DistX = 10'd0;
		Rock_DistY = 10'd0;
		for(int i = 0; i < 15; i++)
		begin
			if(is_Rocketsig[i])
			begin
				Rock_DistX = Rock_DistXsig[i];
				Rock_DistY = Rock_DistYsig[i];
			end
		end
	end
endmodule 
	
module Rocket_Follow(
	input logic				Reset, frame_clk, shoot,
	input logic [14:0]	EnableRock,
	output reg [14:0]		ShootRocket
);

	logic FirePermit;

	always_ff @ (posedge frame_clk)
	begin
		if(Reset)
			ShootRocket <= {15{1'b0}};
		else if(shoot == 1'b1)
		begin
			for(int i = 0; i < 15; i++)
			begin
				if(EnableRock[i] == 1'b0 && FirePermit == 1'b1)
				begin
					ShootRocket <= 1'b1 << i;
					FirePermit <= 1'b0;
					break;
				end
				else
					ShootRocket <= ShootRocket;
			end
		end
		else
		begin
			FirePermit <= 1'b1;
			ShootRocket <= {15{1'b0}};
		end
	end
endmodule 




module Rocket(
	input logic 			Reset, frame_clk, ShootRocket,
	input logic [9:0] 	DrawX, DrawY, SGunX, SGunY,
	input logic				Rocket_Collision,
	output reg [9:0] 		Rock_DistX, Rock_DistY,
	output reg				EnableRock,
	output logic			is_Rocket
);

	logic [9:0] InitY, RockX, RockY;
	
	parameter Rocket_XSize = 10'd3;
	parameter Rocket_YSize = 10'd8;
	parameter [9:0] Rock_X_Step = 0;
	parameter [9:0] Rock_Y_Step = ~(10'd3) + 1'b1;
   parameter [9:0] Ship_X_Min = 10'd0;       // Leftmost point on the X axis
   parameter [9:0] Ship_X_Max = 10'd639;     // Rightmost point on the X axis
   parameter [9:0] Ship_Y_Min = 10'd0;       // Topmost point on the Y axis
   parameter [9:0] Ship_Y_Max = 10'd479;     // Bottommost point on the Y axis

	assign InitY = SGunY - Rocket_YSize;
	
	enum logic [1:0] {Start, Shoot, Stop} currstate, nextstate;
	
	always_comb
	begin
		if(DrawX >= RockX)
		begin
			if(DrawX <= RockX + Rocket_XSize)
			begin
				if(DrawY >= RockY)
				begin
					if(DrawY <= RockY + Rocket_YSize)
					begin
						is_Rocket = EnableRock;
						Rock_DistX = DrawX - RockX;
						Rock_DistY = DrawY - RockY;
					end
					else
					begin
						is_Rocket = 1'b0;
						Rock_DistX = 1'b0;
						Rock_DistY = 1'b0;
					end
				end
				else
				begin
					is_Rocket = 1'b0;
					Rock_DistX = 1'b0;
					Rock_DistY = 1'b0;
				end
			end
			else
			begin
				is_Rocket = 1'b0;
				Rock_DistX = 1'b0;
				Rock_DistY = 1'b0;
			end
		end
		else
		begin
			is_Rocket = 1'b0;
			Rock_DistX = 1'b0;
			Rock_DistY = 1'b0;
		end
	end
	
	always_ff @ (posedge frame_clk)
	begin
		if(Reset == 1'b1)
		begin
			currstate <= Stop;
			RockX <= SGunX;
			RockY <= InitY;
		end
		else
		begin
			currstate <= nextstate;
			if(currstate == Shoot)
			begin
				RockX <= RockX + Rock_X_Step;
				RockY <= RockY + Rock_Y_Step;
			end
			else
			begin
				RockX <= SGunX;
				RockY <= InitY;
			end
		end
	end
	
	always_comb
	begin
		nextstate = currstate;
		EnableRock = 1'b0;
		case(currstate)
			Start:
			begin
				EnableRock = 1'b1;
				nextstate = Shoot;
			end
			Shoot:
			begin
				if((RockX + Rocket_XSize >= Ship_X_Max) || (RockX <= Ship_X_Min) || (RockY + Rocket_YSize >= Ship_Y_Max) || (RockY <= Ship_Y_Min)) // Rocket_Collision is changed to fit MASTERCODE
				begin
					EnableRock = 1'b0;
					nextstate = Stop;
				end
				else if(Rocket_Collision == 1'b1)
				begin
					EnableRock = 1'b0;
					nextstate = Stop;
				end
				else
				begin
					EnableRock = 1'b1;
					nextstate = Shoot;
				end
			end
			Stop:
			begin
				if(ShootRocket == 1'b0)
					EnableRock = 1'b0;
				else
					nextstate = Start;
			end
			default: ;
		endcase
	end
	
endmodule 
			