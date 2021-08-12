module NPC(input frame_clk, Reset, Change,
           input [9:0] DrawX, DrawY,
          
           //AI signals
			  input [9:0] AI_Logic,
           input [9:0] NPCUpdateX [9:0][19:0], NPCUpdateY [9:0][19:0],
			  input AI_Shoot [9:0][19:0],
           input [9:0] NPC_X_Origin [9:0], NPC_Y_Origin [9:0],
			  input [14:0] NPCRock_Collision [9:0],
			  input [9:0] NPC_Collision,
           output NPC_in [9:0],	
           output is_NPC [9:0],	
           output [9:0] NPCDistX, NPCDistY, NPC_RockDistX, NPC_RockDistY,
			  output [14:0] is_NPCRock [9:0]
          );

  logic [9:0] NPCDistX_in [9:0], NPCDistY_in [9:0], NPC_RockDistX_sig [9:0], NPC_RockDistY_sig[9:0];
  
  logic en_sig_NPC [9:0];
  logic [14:0] is_NPCRock_sig [9:0];
  logic [9:0] NPCDistX_wire [9:0], NPCDistY_wire [9:0];
    
  //Note that the logic instianted here is similar to ball.sv in lab 8
/*Citation: Credit goes to Jeremy and a friend for using this break in if statement*/
    always_comb
    begin
    NPC_RockDistX = 10'd0;
    NPC_RockDistY = 10'd0;
    NPCDistX = 10'd0;
    NPCDistY = 10'd0;
    is_NPC = en_sig_NPC;
    is_NPCRock = is_NPCRock_sig;
        for(int i = 0; i < 10; i++)
        begin
            if(is_NPCRock_sig[i][14:0] != {15{1'b0}})
            begin
                NPC_RockDistX = NPC_RockDistX_sig[i][9:0];
                NPC_RockDistY = NPC_RockDistY_sig[i][9:0];
                break;
            end
        end
        for(int i = 0; i < 10; i++)
        begin
            if(en_sig_NPC[i] != 1'b0)
            begin
                NPCDistX = NPCDistX_in[i][9:0];
                NPCDistY = NPCDistY_in[i][9:0];
                break;
            end
        end
    end
 /*End citation*/


	 
  /*Add stuff here for control*/
	/*Create 10 controllers for enemy modules*/
		NPC_Control UMA [9:0] (
			.frame_clk,
			.Reset,
			.DrawX,
			.DrawY,
			.AI_Logic,
			.AI_Shoot,
			.NPCUpdateX,
			.NPCUpdateY,
			.Change,
			.NPC_Collision,
			
			.NPC_X_Origin,
			.NPC_Y_Origin,
			.NPCDistX(NPCDistX_in),
			.NPCDistY(NPCDistY_in),
			.NPC_in,
			.is_NPC(en_sig_NPC),
			.is_NPCRock(is_NPCRock_sig),
			.NPCRockDistX(NPC_RockDistX_sig),
			.NPCRockDistY(NPC_RockDistY_sig),
		);
//Hmm... we should have made 10 seperate controllers for the enemies
//Note for later.

endmodule

/*
*Updates the location of the NPCs and coordinates movements.
*/
module NPC_Control(input frame_clk, Reset, Change,
                   //Collision Dectection
                   input NPC_Collision,   
                  
                   output	NPC_in,
                   output is_NPC,
                   input [9:0] DrawX, DrawY,
//                   input NPCUpdateControl,

                    input [9:0] NPCUpdateX [19:0], NPCUpdateY [19:0], NPC_X_Origin, NPC_Y_Origin, AI_Logic,
						  input AI_Shoot [19:0],
                   output [9:0] NPCDistX, NPCDistY, NPCRockDistX, NPCRockDistY,
						output [14:0] is_NPCRock
                   

                
);
  logic [9:0] NPCX_sig, NPCY_sig, NPCXstep_sig;
  /*
  *Add stuff here for control
  */


  
  NPC_Location NPC_Loc(.*,
    .Reset(Reset || Change),
    .frame_clk,
    .DrawX,
    .DrawY,
	 .AI_Logic,
	 .NPCUpdateX,
	 .NPCUpdateY,
    .NPC_X_Origin,
    .NPC_Y_Origin,
    .NPC_Collision,
    .is_NPC,
    .NPCX(NPCX_sig),
    .NPCY(NPCY_sig),
    .NPCDistX,
    .NPCDistY,
	 .NPC_XStep(NPCXstep_sig),
    .NPC_in
  );
  

			
  NPC_RocketControl NPCRocket_Control(
		.Reset,
		.frame_clk,
		.DrawX,
		.DrawY,
		.AI_Shoot,
		.AI_Logic,
		.NPCX(NPCX_sig),
		.NPCY(NPCY_sig),
		.NPC_X_Step(NPCXstep_sig),
		.is_NPCRock,
		.NPCRockDistX,
		.NPCRockDistY,
		.NPC_in
	);
				

	
		
 endmodule
  
  
  //NPC Location
  //Still not working...................
  
  module NPC_Location(input frame_clk, Reset,
                   input [9:0] DrawX, DrawY, AI_Logic, NPCUpdateX[19:0], NPCUpdateY [19:0], NPC_X_Origin, NPC_Y_Origin,
						 input NPC_Collision,
                      output [9:0] NPCDistX, NPCDistY, NPCX, NPCY, NPC_XStep,
                   output reg is_NPC,
                   output NPC_in   
  );

	parameter NPC_SizeX = 10'd15;
  parameter NPC_SizeY = 10'd17;
  parameter X_Min = 10'd0;
  parameter X_Max = 10'd639;
  parameter Y_Min = 10'd0;
  parameter Y_Max = 10'd479;
  
  logic [9:0] NPC_X_Pos, NPC_Y_Pos, NPC_X_Motion, NPC_Y_Motion;
  
  logic [1:0] KABOOM;
  logic [9:0] DistXOffset;
  
  always_comb
    begin
      if(DrawX >= NPCX && DrawX <= NPCX + NPC_SizeX && DrawY >= NPCY && DrawY <= NPCY + NPC_SizeY)
        begin
          is_NPC = NPC_in || (KABOOM != 2'b0);
          NPCDistX = DrawX - NPCX + DistXOffset;
          NPCDistY = DrawY - NPCY;
        end
      else
        begin
          is_NPC = 1'b0;
          NPCDistX = 10'd0;
          NPCDistY = 10'd0;
        end
    end
  
  always_ff @ (posedge frame_clk)
    begin
      NPC_in <= NPC_in;
      KABOOM <= KABOOM;
      if(Reset == 1'b1)
        begin
          NPC_X_Motion <= 10'd0;
          NPC_Y_Motion <= 10'd0;
          NPC_X_Pos <= NPC_X_Origin;
          NPC_Y_Pos <= NPC_Y_Origin;
          KABOOM <= 2'b0;
          NPC_in <= 1'b1;
        end
      
      else
        begin
          if( (NPC_Y_Pos + NPC_SizeY) >= Y_Max )  // Ship is at the bottom edge, BOUNCE!
            NPC_Y_Motion <= 10'd0;  // 2's complement.
          else if ((NPC_Y_Pos - NPC_SizeY) <= Y_Min)
            NPC_Y_Motion <= 10'd0;
          else if( (NPC_X_Pos + NPC_SizeX) >= X_Max )  // Ship is at the bottom edge, BOUNCE!
            NPC_Y_Motion <= 10'd0;  // 2's complement.
          else if ((NPC_X_Pos - NPC_SizeX) <= X_Min)
            NPC_Y_Motion <= 10'd0;
          
          else
            begin
            /*
            Add Enemy movement here
            */
              NPC_X_Motion <= NPCUpdateX[AI_Logic];
              NPC_Y_Motion <= NPCUpdateY[AI_Logic];
            end
          if((NPC_Collision == 1'b1 && (NPC_in == 1'b1)) || (KABOOM != 2'b0))
            begin
              NPC_in <= 1'b0;
              KABOOM <= KABOOM + 2'b1;
            end
              
           else 
            begin
              NPC_Y_Pos <= NPC_Y_in;
              NPC_X_Pos <= NPC_X_in;
            end
				
        end
    end
  logic [9:0] NPC_X_in, NPC_Y_in;
            
  always_comb
    begin
      NPC_X_in = NPC_X_Pos;
      NPC_Y_in = NPC_Y_Pos;
      DistXOffset = 10'b0001000101;
      case(KABOOM)
        2'b00:
          begin
            if((NPC_Collision == 1'b0) && (NPC_in == 1'b1))
              begin
                NPC_X_in = NPC_X_Pos + NPC_X_Motion;
                NPC_Y_in = NPC_Y_Pos + NPC_Y_Motion;
              end
          end
        2'b01:
          begin
            DistXOffset = 10'b0000110010;
          end
        2'b10:
          begin
            DistXOffset = 10'b0000011001;
          end
        2'b11:
          begin
            DistXOffset = 10'b0000000001;
          end
        default: ;
      endcase
		end
  assign NPCX = NPC_X_Pos;
  assign NPCY = NPC_Y_Pos;
  assign NPC_XStep = NPC_X_Motion;
endmodule
      

		
module AI(input Clk, Reset,
                input[2:0] Curr_Level,
                output reg [9:0] AI_Logic,
                output reg [9:0] NPCUpdateX [9:0][19:0], NPCUpdateY [9:0][19:0],
                output reg [9:0] NPC_X_Origin[9:0], NPC_Y_Origin [9:0],
					 output reg AI_Shoot [9:0][19:0]
               );


		
		logic clkby2;
    initial clkby2 = 0;
    always_ff @ (posedge Clk)
    begin
        clkby2 <= ~clkby2;
    end

    parameter PlusOne = 10'b1;
    parameter MinusOne = (~(PlusOne) + 10'b1);
    parameter PlusThree = 10'd2;
    parameter MinusThree = (~(PlusThree) + 10'b1);
    parameter PlusFive = 10'd3;
    parameter MinusFive = (~(PlusFive) + 10'b1);
	 parameter Still = 10'd0;
    parameter reg [9:0] NoMove [19:0] = '{10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0}; 
    parameter reg [9:0] CircleX [19:0] = '{   19:PlusOne, 18:PlusOne, 17:PlusOne, 16:PlusOne, 15:PlusOne,
                                            14:MinusOne, 13:MinusOne, 12:MinusOne, 11:MinusOne, 10:MinusOne,
                                            9:MinusOne, 8:MinusOne, 7:MinusOne, 6:MinusOne, 5:MinusOne,
                                            4:PlusOne, 3:PlusOne, 2:PlusOne, 1:PlusOne, 0:PlusOne};
    parameter reg [9:0] CircleY [19:0] = '{   PlusOne, PlusOne, PlusOne, PlusOne, PlusOne,
                                            PlusOne, PlusOne, PlusOne, PlusOne, PlusOne,
                                            MinusOne, MinusOne, MinusOne, MinusOne, MinusOne,
                                            MinusOne, MinusOne, MinusOne, MinusOne, MinusOne};
    parameter reg [9:0] BackAndForth [19:0] = '{  PlusThree, MinusThree, PlusThree, MinusThree, PlusThree,
                                                MinusThree, PlusThree, MinusThree, PlusThree, MinusThree,
                                                PlusThree, MinusThree, PlusThree, MinusThree, PlusThree,
                                                MinusThree, PlusThree, MinusThree, PlusThree, MinusThree};
    parameter reg [9:0] EBackAndForth [19:0] = '{  PlusFive, MinusFive, PlusFive, MinusFive, PlusFive,
                                                MinusFive, PlusFive, MinusFive, PlusFive, MinusFive,
                                                PlusFive, MinusFive, PlusFive, MinusFive, PlusFive,
                                                MinusFive, PlusFive, MinusFive, PlusFive, MinusFive};
    parameter reg [9:0] Leftward [19:0] = '{  MinusThree, MinusThree, MinusThree, MinusThree, MinusThree,
                                                MinusThree, MinusThree, MinusThree, MinusThree, MinusThree,
                                                MinusThree, MinusThree, MinusThree, MinusThree, MinusThree,
                                                MinusThree, MinusThree, MinusThree, MinusThree, MinusThree};
    parameter reg [9:0] Rightward [19:0] = '{  PlusThree, PlusThree, PlusThree, PlusThree, PlusThree,
                                                PlusThree, PlusThree, PlusThree, PlusThree, PlusThree,
                                                PlusThree, PlusThree, PlusThree, PlusThree, PlusThree,
                                                PlusThree, PlusThree, PlusThree, PlusThree, PlusThree};
    parameter reg [9:0] ELeftward [19:0] = '{  MinusFive, MinusThree, MinusFive, MinusFive, MinusFive,
                                                MinusFive, MinusFive, MinusFive, MinusFive, MinusFive,
                                                MinusFive, MinusFive, MinusFive, MinusFive, MinusFive,
                                                MinusFive, MinusFive, MinusFive, MinusFive, MinusFive};
    parameter reg [9:0] ERightward [19:0] = '{  PlusFive, PlusFive, PlusFive, PlusFive, PlusFive,
                                                PlusFive, PlusFive, PlusFive, PlusFive, PlusFive,
                                                PlusFive, PlusFive, PlusFive, PlusFive, PlusFive,
                                                PlusFive, PlusFive, PlusFive, PlusFive, PlusFive};			
    parameter reg [9:0] Random1 [19:0] = '{  PlusFive, MinusFive, PlusFive, MinusFive, PlusFive,
                                                MinusFive, Still, Still, Still, Still,
                                                Still, Still, Still, Still, Still,
                                                Still, Still, Still, PlusFive, MinusFive};
    parameter reg [9:0] Random2 [19:0] = '{  PlusFive, MinusFive, Still, Still, PlusFive,
                                                MinusFive, PlusFive, MinusFive, Still, Still,
                                                Still, Still, PlusFive, MinusFive, PlusFive,
                                                MinusFive, PlusFive, MinusFive, Still, Still};																
    parameter reg Enemy_Fire [19:0] = '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                                    1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                                    1'b0, 1'b0, 1'b1, 1'b1, 1'b1,
                                    1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
    always_ff @ (posedge clkby2)
    begin
        if(Reset == 1'b1)
        begin
            AI_Logic <= 10'b0;
        end
        else
        begin
            if(AI_Logic >= 19)
                AI_Logic <= 10'b0;
            else
                AI_Logic <= AI_Logic + 10'b1;
        end
        AI_Shoot <= '{ Enemy_Fire, Enemy_Fire,
                Enemy_Fire, Enemy_Fire,
                Enemy_Fire, Enemy_Fire,
                Enemy_Fire, Enemy_Fire,
                Enemy_Fire, Enemy_Fire };
    end
   always_comb
    begin
        NPC_X_Origin = '{10'd020, 10'd080, 10'd140, 10'd200, 10'd260, 10'd320, 10'd380, 10'd440, 10'd500, 10'd560};
        NPC_Y_Origin = '{10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040};
        NPCUpdateX = '{CircleX, BackAndForth, CircleY, NoMove, BackAndForth,
                    NoMove, NoMove, NoMove, BackAndForth, NoMove};
        NPCUpdateY = '{CircleY, NoMove, CircleX, NoMove, NoMove,
                    NoMove, CircleX, CircleY, NoMove, NoMove};
		case(Curr_Level)
        3'b1 :
		  begin
				NPC_X_Origin = '{10'd040, 10'd102, 10'd164, 10'd226, 10'd288, 10'd350, 10'd412, 10'd474, 10'd536, 10'd598};
				NPC_Y_Origin = '{10'd080, 10'd120, 10'd180, 10'd210, 10'd280, 10'd280, 10'd210, 10'd160, 10'd0140, 10'd0100};
               NPCUpdateX = '{Rightward, Rightward, Rightward, BackAndForth, NoMove,
                            NoMove, BackAndForth, Leftward, Leftward, Leftward};
                NPCUpdateY = '{NoMove, NoMove, NoMove, NoMove, NoMove,
                            NoMove, NoMove, NoMove, NoMove, NoMove};	
		end
			3'd2 :
		begin
 		  NPC_X_Origin = '{10'd040, 10'd102, 10'd164, 10'd226, 10'd288, 10'd350, 10'd412, 10'd474, 10'd536, 10'd598};
		  NPC_Y_Origin = '{10'd0400, 10'd350, 10'd300, 10'd250, 10'd0200, 10'd0200, 10'd250, 10'd300, 10'd350, 10'd400};				
                NPCUpdateX = '{BackAndForth, BackAndForth, BackAndForth, BackAndForth, BackAndForth,
                            BackAndForth, BackAndForth, BackAndForth, BackAndForth, BackAndForth};
                NPCUpdateY = '{NoMove, NoMove, NoMove, NoMove, NoMove,
                            NoMove, NoMove, NoMove, NoMove, NoMove};
		 end
			3'd3 :
		begin
 		  NPC_X_Origin = '{10'd320, 10'd320, 10'd320, 10'd320, 10'd220, 10'd450, 10'd320, 10'd320, 10'd320, 10'd320};
		  NPC_Y_Origin = '{10'd080, 10'd120, 10'd160, 10'd200, 10'd240, 10'd240, 10'd280, 10'd320, 10'd360, 10'd400};				
                NPCUpdateX = '{Leftward, Rightward, Leftward, Rightward, BackAndForth,
                            BackAndForth, Rightward, Leftward, Rightward, Leftward};
                NPCUpdateY = '{NoMove, NoMove, NoMove, NoMove, NoMove,
                            NoMove, NoMove, NoMove, NoMove, NoMove};
			 end
			3'd4 :
		begin
 		  NPC_X_Origin = '{10'd140, 10'd180, 10'd220, 10'd260, 10'd20, 10'd620, 10'd378, 10'd418, 10'd458, 10'd498};
		  NPC_Y_Origin = '{10'd0400, 10'd350, 10'd300, 10'd250, 10'd200, 10'd230, 10'd250, 10'd310, 10'd360, 10'd410};				
                NPCUpdateX = '{EBackAndForth, EBackAndForth, EBackAndForth, EBackAndForth, Leftward,
                            Rightward, Random1, EBackAndForth, Random1, Random2};
                NPCUpdateY = '{NoMove, NoMove, NoMove, NoMove, NoMove,
                            NoMove, NoMove, NoMove, NoMove, NoMove};									 
            end									 
									 

            default : ;
        endcase
    end
	 
endmodule
