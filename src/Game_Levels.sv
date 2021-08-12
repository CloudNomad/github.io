module Game_Levels(
					    input Clk,
                   input Reset,
                   input NPC_in [9:0],
                   input Ship_in, Ship_in2,
                   input [31:0] keycode,
						 input Restart, Start, Ship_Collision,
                   output ShipReset,
                   output Start_Screen,
                   output Game_Over, Game_Clear, Change,
                   output NewGame,
                   output [2:0] Curr_Level
                
);
  
  parameter bit Trick [9:0] = '{10{1'b0}};
  
  parameter restart = 8'h15;
  parameter up = 8'h52;
  parameter left = 8'h50;
  parameter down = 8'h51;
  parameter right = 8'h4F;
  parameter shoot  = 8'h2C;
  parameter start = 8'h28;		//Enter Key
  
  enum logic [3:0] {Halted, Pause1, Pause2, Pause3, Pause4, Pause5, Level1, Level2, Level3, Level_4, Final_Level, GameOver, GameClear} curr_state, next_state;
  
 
  always_ff @ (posedge Clk or posedge Reset)
    begin : Assign_Next_State
      if(Reset)
        begin
          curr_state <= Halted;
        end
      else
        begin
          curr_state <= next_state;
        end
    end
  
  logic Ships_dead;
  
  always_comb
  begin
	Ships_dead = Ship_in | Ship_in2;
  end
  
  
  always_comb
    begin
      next_state = curr_state;
      ShipReset = Restart;
      Start_Screen = 1'b0;
      Game_Over = 1'b0;
		Game_Clear = 1'b0;
      Curr_Level = 3'b0;
      NewGame = Restart;
		Change = 1'b0;
      
        case(curr_state)
         
            Halted :
            begin
                if(Start)
                begin
                    next_state = Level1;
                end
                ShipReset = 1'b1;
                Start_Screen = 1'b1;
                NewGame = 1'b1;
					 Game_Clear = 1'b0;
					 Game_Over = 1'b0;
            end
           
            Level1 :
            begin
                Curr_Level = 3'd0;
                if((NPC_in == Trick) && ((Ship_in == 1'b1) || (Ship_in2 == 1'b1)))
                begin
                    next_state = Pause1;
                end
                else if(Ships_dead == 1'b0)
                begin
                    next_state = GameOver;
                end
            end
 
            Level2 :
            begin
                Curr_Level = 3'd1;
					 Change = 1'b0;
                if(NPC_in == Trick && ((Ship_in == 1'b1) || (Ship_in2 == 1'b1)))
                    next_state = Pause2;
                else if(Ships_dead == 1'b0)
                    next_state = GameOver;
            end
           
            Level3 :
            begin
                Curr_Level = 3'd2;
					 Change = 1'b0;
                if(NPC_in == Trick && ((Ship_in == 1'b1) || (Ship_in2 == 1'b1)))
                    next_state = Pause3;
                else if(Ships_dead == 1'b0)
                    next_state = GameOver;
            end
				
				Level_4 :
            begin
                Curr_Level = 3'd3;
					 Change = 1'b0;
                if(NPC_in == Trick && ((Ship_in == 1'b1) || (Ship_in2 == 1'b1)))
                    next_state = Pause4;
                else if(Ships_dead == 1'b0)
                    next_state = GameOver;
            end
				
				Final_Level :
            begin
                Curr_Level = 3'd4;
					 Change = 1'b0;
                if(NPC_in == Trick && ((Ship_in == 1'b1) || (Ship_in2 == 1'b1)))
                    next_state = Pause5;
                else if(Ships_dead == 1'b0)
                    next_state = GameOver;
            end
           
            Pause1 :
            begin
                ShipReset = 1'b1;
                Curr_Level = 3'd1;
					 Change = 1'b1;
                        next_state = Level2;
            end
            Pause2 :
            begin
                ShipReset = 1'b1;
                Curr_Level = 3'd2;
					 Change = 1'b1;
                        next_state = Level3;
            end
            Pause3 :
            begin
                ShipReset = 1'b1;
					 Curr_Level = 3'd3;
                next_state = Level_4;
            end
            Pause4 :
            begin
                ShipReset = 1'b1;
					 Curr_Level = 3'd4;
                next_state = Final_Level;
            end
            Pause5 :
            begin
                ShipReset = 1'b1;
                next_state = GameClear;
            end				
				
				GameClear :
				begin
					ShipReset = 1'b1;
					Game_Clear = 1'b1;
					if(Restart)
						next_state = Halted;
				end
            GameOver :
            begin
                ShipReset = 1'b1;
                Game_Over = 1'b1;
                if(Restart)
                    next_state = Halted;
            end
            default : ;
        endcase

    end
  
endmodule
        