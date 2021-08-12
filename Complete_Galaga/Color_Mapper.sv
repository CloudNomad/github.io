//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

 //color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_Ship, is_Ship2, is_Rocket, is_Rocket2, is_NPC, is_NPC_Rocket,            // Whether current pixel belongs to ball 
							  input 			[3:0] Current_Level,
                       input 					StartScreen,                        //   or background (computed in ball.sv)
                       input					Game_Over, Game_Clear,
							  input        [9:0] DrawX, DrawY, Ship_DistX, Ship_DistY, Rock_DistX, Rock_DistY, Ship_DistX2, Ship_DistY2, Rock_DistX2, Rock_DistY2,
							  input			[9:0] NPCDistX, NPCDistY, NPCRockDistX, NPCRockDistY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
							
    logic [7:0] Red, Green, Blue, ShipR, ShipG, ShipB, RockR, RockB, RockG, ShipR2, ShipG2, ShipB2, RockR2, RockB2, RockG2;
	 logic [7:0] NPCR, NPCG, NPCB, NPCR2, NPCG2, NPCB2, NPCR3, NPCG3, NPCB3, NPCRR, NPCRG, NPCRB, Demon_B, Demon_G, Demon_R;
	 logic [7:0] SSR = 8'hff, SSG = 8'hff, SSB = 8'hff;
	 int DistX, DistY;
	 
	 parameter [9:0] SS_XStart = 10'd207;
	 parameter [9:0] SS_YStart = 10'd17;
	 parameter [9:0] SS_Xsize = 10'd227;
	 parameter [9:0] SS_Ysize = 10'd184;
    parameter Ship_YSize = 10'd19;
    parameter Rock_YSize = 10'd8;
    parameter NPC_YSize = 10'd17;

    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on signal
    always_comb
    begin: RGB_Display
	 
	  if(StartScreen == 1'b1)
        begin
            //if(DrawX >= SplashXStart && DrawX <= SplashXStart + SplashXSize && DrawY >= SplashYStart && DrawY <= SplashYStart + SplashYSize)
            //begin
                DistX = DrawX - SS_XStart;
                DistY = DrawY - SS_YStart;
                Red = SSR;
                Green = SSG;
                Blue = SSB;
			end
	 else			 
	 if(Game_Over == 1'b1)
		begin
			DistX = 0;
			DistY = 0;
			Red = 8'haf;
			Green = 8'h00;
			Blue =  8'h00;
		end
	else
	if(Game_Clear == 1'b1)
	begin
		DistX = 0;
		DistY = 0;
		Red = 8'h00;
		Green = 8'haf;
		Blue = 8'h00;
	end
	else
	begin
     if (is_Ship == 1'b1) 
     begin
         DistX = Ship_DistX;
         DistY = Ship_DistY;
         Red = ShipR;
         Green = ShipG;
         Blue = ShipB;
     end
     else if (is_Ship2 == 1'b1) 
     begin
         DistX = Ship_DistX2;
         DistY = Ship_DistY2;
         Red = ShipR2;
         Green = ShipG2;
         Blue = ShipB2;
     end
	  else if(is_Rocket == 1'b1)
	  begin
			DistX = Rock_DistX;
			DistY = Rock_DistY;
			Red = RockR;
			Green = RockG;
			Blue = RockB;
	  end
	  else if(is_Rocket2 == 1'b1)
	  begin
			DistX = Rock_DistX2;
			DistY = Rock_DistY2;
			Red = RockR2;
			Green = RockG2;
			Blue = RockB2;
	  end
		else if(is_NPC == 1'b1)
		begin
			DistX = NPCDistX;
			DistY = NPCDistY;
			case(Current_Level)
				3'd1:
				begin
					Red = NPCR2;
					Green = NPCG2;
					Blue = NPCB2;
				end
				3'd2:
				begin
					Red = NPCR3;
					Green = NPCG3;
					Blue = NPCB3;
				end
				3'd3:
				begin
					Red = NPCR2;
					Green = NPCG2;
					Blue = NPCB;
				end
				3'd4:
				begin
					Red = Demon_R;
					Green = Demon_G;
					Blue = Demon_B;
				end				
				default:
				begin
					Red = NPCR;
					Green = NPCG;
					Blue = NPCB;
				end
			endcase
		end
		else if(is_NPC_Rocket == 1'b1)
		begin
			DistX = NPCRockDistX;
			DistY = NPCRockDistY;
			Red = NPCRR;
			Green = NPCRG;
			Blue = NPCRB;
		end
     else 
     begin
         // Background with nice color gradient
         DistX = 0;
         DistY = 0;
         Red = 8'h00; 
         Green = 8'h00;
			Blue = 8'h00;
         //Blue = 8'h7f - {1'b0, DrawX[9:3]};
     end
	end 
	end
	 
	 Ship_Sprites ships(.DrawX(DistX), .DrawY(Ship_YSize-DistY), .ShipR(ShipR), .ShipG(ShipG), .ShipB(ShipB));
	 ship_rocket rocketsprite(.DrawX(DistX), .DrawY(Rock_YSize-DistY), .SRockR(RockR), .SRockG(RockG), .SRockB(RockB));
	 EnemyBeeSprite Hornet(.SpriteX(DistX), .SpriteY(NPC_YSize-DistY), .SpriteR(NPCR), .SpriteG(NPCG), .SpriteB(NPCB));
    BlueEnemySprite Beetle(.SpriteX(DistX), .SpriteY(NPC_YSize-DistY), .SpriteR(NPCR2), .SpriteG(NPCG2), .SpriteB(NPCB2));
	 RealBeeSprite Wasp(.SpriteX(DistX), .SpriteY(NPC_YSize-DistY), .SpriteR(NPCR3), .SpriteG(NPCG3), .SpriteB(NPCB3));
	 Demon Boss(.SpriteX(DistX), .SpriteY(NPC_YSize-DistY), .SpriteR(Demon_R), .SpriteG(Demon_G), .SpriteB(Demon_B));
    EnemyShipProjectileSprite esps(.SpriteX(DistX), .SpriteY(DistY), .SpriteR(NPCRR), .SpriteG(NPCRG), .SpriteB(NPCRB));
	 
	 Ship_Sprites2 ships2(.DrawX(DistX), .DrawY(Ship_YSize-DistY), .ShipR(ShipR2), .ShipG(ShipG2), .ShipB(ShipB2));
	 ship_rocket2 rocketsprite2(.DrawX(DistX), .DrawY(Rock_YSize-DistY), .SRockR(RockR2), .SRockG(RockG2), .SRockB(RockB2));
	 
endmodule
