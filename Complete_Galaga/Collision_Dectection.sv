module Collision_Detection(
                    input frame_clk, VGA_CLK, Reset,
                    //input [9:0] DrawX, DrawY,
                    input is_Ship,
                    input [14:0] is_Rocket,
                    input is_Ship2,
                    input [14:0] is_Rocket2,
                    input is_NPC[9:0], 
                    input [14:0] is_NPC_Rocket [9:0],
                    output rising_edge,
                    output Ship_Collision,
                    output [14:0] Rocket_Collision,
                    output Ship_Collision2,
                    output [14:0] Rocket_Collision2,
                    output [9:0] NPC_Collision,
                    output [14:0] NPC_Rocket_Collision [9:0],
                    output  is_Rocket_cm, is_Rocket_cm2, is_NPCRocket_cm, is_NPC_cm);

    logic fc_sample;
    initial
    begin
        fc_sample = 1'b0;
    end
    
    assign rising_edge = fc_sample;

    logic Ship_Collision_sig, Ship_Collision_sig2;
    logic [14:0] Rocket_Collision_sig, Rocket_Collision_sig2;
    logic [9:0] NPC_Collision_sig;
    logic [14:0] NPC_Rocket_Collision_sig [9:0];
	 typedef logic [9:0] logic_NE_t;

   parameter bit [14:0] PC0 = {15{1'b0}};
   parameter bit [14:0] PC1 = {15{1'b0}};
	parameter bit [9:0] ESC0 = {10{1'b0}};
   parameter bit [14:0] EPC0 [9:0] =  '{10{{15{1'b0}}}};


    always_ff @ (posedge VGA_CLK)
    begin
        fc_sample <= frame_clk;
        if(Reset | (~fc_sample & frame_clk))
        begin
            Ship_Collision <= 1'b0;
            Ship_Collision2 <= 1'b0;
            Rocket_Collision <= PC0;
            Rocket_Collision2 <= PC0;
            NPC_Collision <= ESC0;
            NPC_Rocket_Collision <= EPC0;
        end
        else
        begin
            Ship_Collision <= Ship_Collision | Ship_Collision_sig;
            Ship_Collision2 <= Ship_Collision2 | Ship_Collision_sig2;
            Rocket_Collision <= Rocket_Collision | Rocket_Collision_sig;
            Rocket_Collision2 <= Rocket_Collision2 | Rocket_Collision_sig2;
            NPC_Collision <= NPC_Collision | NPC_Collision_sig;
            NPC_Rocket_Collision <= NPC_Rocket_Collision_sig;
        end
    end
    always_comb
    begin
        for(int i = 0; i < 9; i++)
        begin
            NPC_Rocket_Collision_sig[i][14:0] = NPC_Rocket_Collision[i][14:0] | is_NPC_Rocket[i][14:0] & {15{is_Ship}};
        end
    end
    
    assign Ship_Collision_sig = is_Ship & ((is_NPC_Rocket != EPC0)|(logic_NE_t'(is_NPC) != ESC0));
    assign Ship_Collision_sig2 = is_Ship2 & ((is_NPC_Rocket != EPC0)|(logic_NE_t'(is_NPC) != ESC0));
    logic_NE_t ess;
    assign ess = logic_NE_t'(is_NPC);
    assign NPC_Collision_sig = ess & {10{((is_Rocket != PC0) | (is_Rocket2 != PC1) | is_Ship | is_Ship2)}};
	 assign Rocket_Collision_sig = is_Rocket & {15{(logic_NE_t'(is_NPC) != ESC0)}};
    assign Rocket_Collision_sig2 = is_Rocket2 & {15{(logic_NE_t'(is_NPC) != ESC0)}};


    assign is_Rocket_cm = |is_Rocket;
	 assign is_Rocket_cm2 = |is_Rocket2;
    assign is_NPC_cm = is_NPC.or;
    assign is_NPCRocket_cm = |(is_NPC_Rocket.or);

endmodule 