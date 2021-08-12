module NPC_RocketControl(
	input logic				Reset, frame_clk, NPC_in,
	input logic [9:0]		DrawX, DrawY, NPCX, NPCY, NPC_X_Step, AI_Logic,
	input logic 			AI_Shoot [19:0],
	output logic [14:0]	is_NPCRock,
	output logic [9:0]	NPCRockDistX, NPCRockDistY
);

	logic [14:0] is_NPCRock_sig, NPCRock_in_sig, NPC_Shoot_sig;
	logic [9:0] NPCRockDistX_sig [14:0], NPCRockDistY_sig [14:0];
	logic [9:0] ShipGunX_offset = 5;
	logic [9:0] ShipGunY_offset = 7;

	always_comb
	begin
		NPCRockDistX = 10'd0;
		NPCRockDistY = 10'd0;
		is_NPCRock = is_NPCRock_sig;
		for(int i = 0; i < 15; i++)
		begin
			if(is_NPCRock_sig[i] == 1'b1)
			begin
				NPCRockDistX = NPCRockDistX_sig[i];
				NPCRockDistY = NPCRockDistY_sig[i];
				break;
			end
		end
	end
	
	NPCRock_follower NPCfollowRocket(
		.Reset,
		.frame_clk,
		.NPC_in,
		.AI_Logic,
		.NPCRock_in(NPCRock_in_sig),
		.AI_Shoot,
		.NPC_Shoot(NPC_Shoot_sig)
	);
	
	NPC_Rocket NPCRocket [14:0] (
		.Reset,
		.frame_clk,
		.NPC_Shoot(NPC_Shoot_sig),
		.NPCGunX(NPCX + ShipGunX_offset),
		.NPCGunY(NPCY + ShipGunY_offset),
		.NPC_X_Step,
		.DrawX,
		.DrawY,
		.NPC_RockDistX(NPCRockDistX_sig),
		.NPC_RockDistY(NPCRockDistY_sig),
		.is_NPCRock(is_NPCRock_sig),
		.NPCRock_in(NPCRock_in_sig)
	);


endmodule 
	

module NPCRock_follower(
	input logic				Reset, frame_clk, NPC_in,
	input logic [9:0]		AI_Logic,
	input logic [14:0]	NPCRock_in,
	input logic 			AI_Shoot [19:0],
	output reg [14:0]		NPC_Shoot
);
	
	always_ff @ (posedge frame_clk)
	begin
		if(Reset)
			NPC_Shoot <= {15{1'b0}};
		else
		begin
			if(AI_Shoot[AI_Logic] == 1'b1 && NPC_in == 1'b1)
			begin
				for(int i = 0; i < 15; i++)
				begin
					if(NPCRock_in[i] == 1'b0)
					begin
						NPC_Shoot <= 1'b1 << i;
						break;
					end
					else
						NPC_Shoot <= NPC_Shoot;
				end
			end
			else
				NPC_Shoot <= {15{1'b0}};
		end
	end
	
endmodule

	
module NPC_Rocket(
	input logic				Reset, frame_clk, NPC_Shoot,
	input logic [9:0]		NPCGunX, NPCGunY, NPC_X_Step, DrawX, DrawY,
	output reg [9:0]		NPC_RockDistX, NPC_RockDistY,
	output reg				is_NPCRock, NPCRock_in
);

	logic [9:0] NPCRock_Y_Origin, NPCRock_X_Step, NPCRockX, NPCRockY;
	
	parameter [9:0] NPCRock_Y_Step = 10'b1;
	parameter NPC_RockXSize = 10'd3;
	parameter NPC_RockYSize = 10'd8;
   parameter MinX = 10'd0;       // Leftmost point on the X axis
   parameter MaxX = 10'd639;     // Rightmost point on the X axis
   parameter MinY = 10'd0;       // Topmost point on the Y axis
   parameter MaxY = 10'd479;     // Bottommost point on the Y axis

	assign NPCRock_Y_Origin = NPCGunY+NPC_RockYSize;
	
	enum logic [1:0] {Start, Shoot, Stop} currstate, nextstate;

	always_comb
	begin
		if(DrawX >= NPCRockX && DrawX <= NPCRockX + NPC_RockXSize && DrawY >= NPCRockY && DrawY <= NPCRockY + NPC_RockYSize)
		begin
			is_NPCRock = NPCRock_in;
			NPC_RockDistX = DrawX - NPCRockX;
			NPC_RockDistY = DrawY - NPCRockY;
		end
		else
		begin
			is_NPCRock = 1'b0;
			NPC_RockDistX = 10'd0;
			NPC_RockDistY = 10'd0;
		end
	end
	
	always_ff @ (posedge frame_clk)
	begin
		if(Reset == 1'b1)
		begin
			currstate <= Stop;
			NPCRockX <= NPCGunX;
			NPCRockY <= NPCRock_Y_Origin;
		end
		else
		begin
			currstate <= nextstate;
			case(currstate)
				Shoot:
				begin
					NPCRock_X_Step <= NPCRock_X_Step;
					NPCRockX <= NPCRockX + NPCRock_X_Step;
					NPCRockY <= NPCRockY + NPCRock_Y_Step;
				end
				default:
				begin
					NPCRock_X_Step <= NPC_X_Step;
					NPCRockX <= NPCGunX;
					NPCRockY <= NPCRock_Y_Origin;
				end
			endcase
		end
	end
	
	always_comb
	begin
		nextstate = currstate;
		NPCRock_in = 1'b0;
		case(currstate)
			Start:
			begin
				NPCRock_in = 1'b1;
				nextstate = Shoot;
			end
			Shoot:
			begin
				if((NPCRockX + NPC_RockYSize >= MaxX) || (NPCRockX <= MinX) || (NPCRockY + NPC_RockYSize >= MaxY) || (NPCRockY <= MinY))
				begin
					NPCRock_in = 1'b0;
					nextstate = Stop;
				end
				else
				begin
					NPCRock_in = 1'b1;
					nextstate = Shoot;
				end
			end
			Stop:
			begin
				if(NPC_Shoot == 1'b1)
					nextstate = Shoot;
				else
					NPCRock_in = 1'b0;
			end
			default: ;
		endcase
	end

    
  
endmodule

