// Arcade shooter: Galaga Space Invasion
// Group Members: Chulwon Choi, Joshua Lewis

module  Galaga         (
				input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 input		  [17:0] SW,
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );    
    logic Reset_h, Vert_Sig, Clk;
    logic [9:0] X_Pos, Y_Pos;
     logic [31:0] keycode;
    logic is_Ship_sig;
    logic Ship_Collision_sig;
	 
    // Ship Rocket Signals
    logic [14:0] is_Rocket_sig;
    logic [14:0] Rocket_Collision_sig;
    logic [14:0] Rocket_Collision_sig2;

    // NPCs Ship Signals
    logic [9:0] NPC_Collision_sig;
    logic is_NPC_sig [9:0];
	 
    // NPCs Rocket Signals
    logic [14:0] NPCRocket_Collision_sig [9:0];
    logic [14:0] is_NPCRocket [9:0];


    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk)
	 begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
	 
	 assign VGA_VS = Vert_Sig;
    
    logic rising_edge;
    


    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
     

         hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     //The connections for nios_system might be named different depending on how you set up Qsys
     lab7_soc nios_system(
                                         .clk_clk(Clk),         
                                         .reset_reset_n(KEY[0]),   
                                         .sdram_wire_addr(DRAM_ADDR), 
                                         .sdram_wire_ba(DRAM_BA),   
                                         .sdram_wire_cas_n(DRAM_CAS_N),
                                         .sdram_wire_cke(DRAM_CKE),  
                                         .sdram_wire_cs_n(DRAM_CS_N), 
                                         .sdram_wire_dq(DRAM_DQ),   
                                         .sdram_wire_dqm(DRAM_DQM),  
                                         .sdram_wire_ras_n(DRAM_RAS_N),
                                         .sdram_wire_we_n(DRAM_WE_N), 
                                         .sdram_clk_clk(DRAM_CLK),
                                         .keycode_export(keycode),  
                                         .otg_hpi_address_export(hpi_addr),
                                         .otg_hpi_data_in_port(hpi_data_in),
                                         .otg_hpi_data_out_port(hpi_data_out),
                                         .otg_hpi_cs_export(hpi_cs),
                                         .otg_hpi_r_export(hpi_r),
                                         .otg_hpi_w_export(hpi_w));
    

    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));

   VGA_controller vga_controller_instance(
			.Clk				(Clk),
			.Reset			(Reset_h),
			.VGA_HS			(VGA_HS),// Horizontal sync pulse.  Active low
			.VGA_VS			(Vert_Sig),// Vertical sync pulse.  Active low
			.VGA_CLK			(VGA_CLK), // 25 MHz VGA clock input
			.VGA_BLANK_N	(VGA_BLANK_N),// Blanking interval indicator.  Active low.
			.VGA_SYNC_N		(VGA_SYNC_N),// Composite Sync signal.  Active low.  We don't use it in this lab, but the video DAC on the DE2 board requires an input for it.
			.DrawX			(X_Pos),// horizontal coordinate
			.DrawY			(Y_Pos)// vertical coordinate
	 );

logic up, down, left, right, shoot, up2, down2, left2, right2, shoot2, Restart, Start;

	//Module for reading multiple key inputs. Necessary for 2 player mode.
	keycode_read keyread(
		.keycode(keycode),
		.up(up),
		.down(down),
		.left(left),
		.right(right),
		.shoot(shoot),
		.up2(up2),
		.down2(down2),
		.left2(left2),
		.right2(right2),
		.shoot2(shoot2),
		.Restart(Restart),
		.Start(Start),
	);				

	 Ship_Control ship_instance(
			.Clk(Clk),
			.Reset(Reset_h | ~KEY[1] | NewGame),
			.ShipReset,
			.frame_clk(Vert_Sig),
			.up(up),
			.down(down),
			.left(left),
			.right(right),
			.Restart(Restart),
			.SW(SW[0]),
			.Ship_Collision(Ship_Collision_sig & SW[1]),
			.shoot(shoot),
			.DrawX(X_Pos),
			.DrawY(Y_Pos),
			.is_Ship(is_Ship_sig),
			.Ship_in(Ship_in_sig),
			.Ship_DistX(Ship_DistX_sig),
			.Ship_DistY(Ship_DistY_sig),
			.is_Rocket(is_Rocket_sig),
			.Rock_DistX(Rock_DistX_sig),
			.Rock_DistY(Rock_DistY_sig),
			.Rocket_Collision(Rocket_Collision_sig)
		);
	//Player 2 logic signals
    logic is_Ship_sig2;
    logic Ship_Collision_sig2;
	 logic [9:0] Ship_DistX_sig2, Ship_DistY_sig2, Rock_DistX_sig2, Rock_DistY_sig2;
    logic [14:0] is_Rocket_sig2;
	 
	Ship_Control2 ship_instance2(
			.Clk(Clk & SW[0]),
			.Reset(Reset_h | ~KEY[1] | NewGame),
			.ShipReset,
			.frame_clk(Vert_Sig & SW[0]),
			.up(up2),
			.down(down2),
			.left(left2),
			.right(right2),
			.Restart(Restart),
			.Ship_Collision(Ship_Collision_sig2 & SW[1]),
			.shoot(shoot2),
			.DrawX(X_Pos),
			.DrawY(Y_Pos),
			.is_Ship(is_Ship_sig2),
			.Ship_in(Ship_in_sig2),
			.Ship_DistX(Ship_DistX_sig2),
			.Ship_DistY(Ship_DistY_sig2),
			.is_Rocket(is_Rocket_sig2 ),
			.Rock_DistX(Rock_DistX_sig2),
			.Rock_DistY(Rock_DistY_sig2),
			.Rocket_Collision(Rocket_Collision_sig2)
		);
	 
    NPC NPCs (.*,
            .frame_clk(Vert_Sig),
				.Reset(Reset_h | ~KEY[1] | ShipReset),
            .DrawX(X_Pos),
            .DrawY(Y_Pos),
				.Change,
            // Logic signals
            .AI_Logic(AI_Logic_sig),
            .AI_Shoot(AI_Shoot_sig),
            .NPCUpdateX(NPCUpdateX_sig),
            .NPCUpdateY(NPCUpdateY_sig),
            .NPC_X_Origin(NPC_X_Origin_sig),
            .NPC_Y_Origin(NPC_Y_Origin_sig),
            // Collision unit signals
            .NPC_Collision(NPC_Collision_sig),
            .NPCRock_Collision(NPCRocket_Collision_sig),
            // Color mapper signals
            .is_NPC(is_NPC_sig),
            .NPC_in(NPC_in_sig),
            .NPCDistX(NPCDistX_sig),
            .NPCDistY(NPCDistY_sig),
            .is_NPCRock(is_NPCRocket),
            .NPC_RockDistX(NPC_RockDistX_sig),
            .NPC_RockDistY(NPC_RockDistY_sig)
    );
	 	
    // NPCs Logic
    logic [9:0] AI_Logic_sig, NPCUpdateX_sig [9:0][19:0], NPCUpdateY_sig [9:0][19:0];
    logic [9:0] NPC_X_Origin_sig [9:0], NPC_Y_Origin_sig [9:0];
    logic AI_Shoot_sig [9:0][19:0];
	 
		AI AI_Controller(
			.Clk(Vert_Sig),
			.Curr_Level(Current_Level_sig),
			.Reset(Reset_h | ~KEY[1] | ShipReset),
			.AI_Logic(AI_Logic_sig),
			.NPCUpdateX(NPCUpdateX_sig),
			.NPCUpdateY(NPCUpdateY_sig),
			.NPC_X_Origin(NPC_X_Origin_sig),
			.NPC_Y_Origin(NPC_Y_Origin_sig),
			.AI_Shoot(AI_Shoot_sig)
		);
					 
    logic [9:0] Ship_DistX_sig, Ship_DistY_sig, Rock_DistX_sig, Rock_DistY_sig;
    logic [9:0] NPCDistX_sig, NPCDistY_sig, NPC_RockDistX_sig, NPC_RockDistY_sig;
						  
		  Collision_Detection Collision_Dection_Inputs(
                    .frame_clk(VGA_VS),
                    .VGA_CLK(VGA_CLK),
                    .rising_edge(rising_edge),
                    .Reset(Reset_h | ~KEY[1] | ShipReset),
                    .is_Ship(is_Ship_sig),
                    .is_Ship2(is_Ship_sig2),
                    .is_Rocket(is_Rocket_sig),
                    .is_Rocket2(is_Rocket_sig2),
                    .is_NPC(is_NPC_sig),
                    .is_NPC_Rocket(is_NPCRocket),
                    .Ship_Collision(Ship_Collision_sig),
                    .Rocket_Collision(Rocket_Collision_sig),
                    .Ship_Collision2(Ship_Collision_sig2),
                    .Rocket_Collision2(Rocket_Collision_sig2),
                    .NPC_Collision(NPC_Collision_sig),
						  .NPC_Rocket_Collision(NPCRocket_Collision_sig),
						  .is_Rocket_cm(is_Rocket_0),
						  .is_Rocket_cm2(is_Rocket_02),
						  .is_NPCRocket_cm(is_NPCRocket_0),
						  .is_NPC_cm(is_NPC_0)
                    );
						  
    logic is_Rocket_0, is_NPC_0, is_NPCRocket_0;

	color_mapper color_instance(
			.is_Ship(is_Ship_sig),
			.is_Ship2(is_Ship_sig2 & SW[0]),
			.is_Rocket(is_Rocket_0),
			.is_Rocket2(is_Rocket_02),
			.is_NPC(is_NPC_0),
			.is_NPC_Rocket(is_NPCRocket_0),
			.Current_Level(Current_Level_sig),
			.StartScreen(StartScreen_Sig),
			.Game_Over(Game_Over_sig),
			.Game_Clear(Game_Clear_sig),
			.DrawX(X_Pos),
			.DrawY(Y_Pos),
			.Ship_DistX(Ship_DistX_sig),
			.Ship_DistY(Ship_DistY_sig),
			.Ship_DistX2(Ship_DistX_sig2),
			.Ship_DistY2(Ship_DistY_sig2),
			.Rock_DistX(Rock_DistX_sig),
			.Rock_DistY(Rock_DistY_sig),
			.Rock_DistX2(Rock_DistX_sig2),
			.Rock_DistY2(Rock_DistY_sig2),
			.NPCDistX(NPCDistX_sig),
			.NPCDistY(NPCDistY_sig),
			.NPCRockDistX(NPC_RockDistX_sig),
			.NPCRockDistY(NPC_RockDistY_sig),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B)
	);
	
				
    logic NPC_in_sig[9:0];
    logic Ship_in_sig, Ship_in_sig2, ShipReset, NewGame, Change;
    logic StartScreen_Sig, Game_Over_sig, Game_Clear_sig;
    logic [2:0] Current_Level_sig;
	 
	 
		Game_Levels GL(
			.Clk(Vert_Sig),
			.Reset(Reset_h | ~KEY[1]),
			.NPC_in(NPC_in_sig),
			.Ship_in(Ship_in_sig),
			.Ship_in2(Ship_in_sig2 & SW[0]),
			.Ship_Collision(Ship_Collision_sig),
			.keycode,
			.ShipReset,
			.Restart,
			.Start,
			.NewGame,
			.Change,
			.Start_Screen(StartScreen_Sig),
			.Game_Over(Game_Over_sig),
			.Game_Clear(Game_Clear_sig),
			.Curr_Level(Current_Level_sig)
			);
		

                                                         
     HexDriver hex_inst_0 (keycode[3:0], HEX0);
     HexDriver hex_inst_1 (keycode[7:4], HEX1);
     HexDriver hex_inst_2 (keycode[11:8], HEX2);
     HexDriver hex_inst_3 (keycode[15:12], HEX3);

endmodule
