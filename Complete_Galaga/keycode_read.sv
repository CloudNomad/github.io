module keycode_read(
	input logic [31:0] keycode,
	output logic up, down, left, right, shoot, Restart, up2, down2, left2, right2, shoot2, Start
);
// up - 8h'52
// down - 8h'51
// left - 8h'50
// right - 8h'4F
// shoot - 8h'2C // 38 for 2p
//38
// Restart - 8'h15n
// Start - 8'h28
// w(up2) - 1a, s 16, a 04, d 07, g 0a

	  assign up = (keycode[31:24] == 8'h52 |
						keycode[23:16] == 8'h52 |
						keycode[15: 8] == 8'h52 |
						keycode[ 7: 0] == 8'h52);
	  assign down = (keycode[31:24] == 8'h51 |
						keycode[23:16] == 8'h51 |
						keycode[15: 8] == 8'h51 |
						keycode[ 7: 0] == 8'h51);
	  assign left = (keycode[31:24] == 8'h50 |
						keycode[23:16] == 8'h50 |
						keycode[15: 8] == 8'h50 |
						keycode[ 7: 0] == 8'h50);
	  assign right = (keycode[31:24] == 8'h4F |
						keycode[23:16] == 8'h4F |
						keycode[15: 8] == 8'h4F |
						keycode[ 7: 0] == 8'h4F);
	  assign shoot = (keycode[31:24] == 8'h38 |
						keycode[23:16] == 8'h38 |
						keycode[15: 8] == 8'h38 |
						keycode[ 7: 0] == 8'h38);
	  assign Restart = (keycode[31:24] == 8'h15 |
						keycode[23:16] == 8'h15 |
						keycode[15: 8] == 8'h15 |
						keycode[ 7: 0] == 8'h15);
	  assign Start = (keycode[31:24] == 8'h28 |
						keycode[23:16] == 8'h28 |
						keycode[15: 8] == 8'h28 |
						keycode[ 7: 0] == 8'h28);

						
	  assign up2 = (keycode[31:24] == 8'h1A |
						keycode[23:16] == 8'h1A |
						keycode[15: 8] == 8'h1A |
						keycode[ 7: 0] == 8'h1A);
	  assign down2 = (keycode[31:24] == 8'h16 |
						keycode[23:16] == 8'h16 |
						keycode[15: 8] == 8'h16 |
						keycode[ 7: 0] == 8'h16);
	  assign left2 = (keycode[31:24] == 8'h04 |
						keycode[23:16] == 8'h04 |
						keycode[15: 8] == 8'h04 |
						keycode[ 7: 0] == 8'h04);
	  assign right2 = (keycode[31:24] == 8'h07 |
						keycode[23:16] == 8'h07 |
						keycode[15: 8] == 8'h07 |
						keycode[ 7: 0] == 8'h07);
	  assign shoot2 = (keycode[31:24] == 8'h0A |
						keycode[23:16] == 8'h0A |
						keycode[15: 8] == 8'h0A |
						keycode[ 7: 0] == 8'h0A);
						
endmodule 