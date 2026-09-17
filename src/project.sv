`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  // --------------------------------------------------------------------------
  // I/O
  // --------------------------------------------------------------------------
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;
   
  wire _unused_ok = &{ena, ui_in[7], ui_in[4:0], uio_in};

  wire hsync;
  wire vsync;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;

  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  hvsync_generator vga_sync_gen (
      .clk(clk),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(video_active),
      .hpos(pix_x),
      .vpos(pix_y)
  );

  // --------------------------------------------------------------------------
  // Gamepad
  // --------------------------------------------------------------------------
  wire inp_b, inp_y, inp_select, inp_start;
  wire inp_up, inp_down, inp_left, inp_right;
  wire inp_a, inp_x, inp_l, inp_r;

  gamepad_pmod_single driver (
      .rst_n(rst_n),
      .clk(clk),
      .pmod_data(ui_in[6]),
      .pmod_clk(ui_in[5]),
      .pmod_latch(ui_in[4]),
      .b(inp_b),
      .y(inp_y),
      .select(inp_select),
      .start(inp_start),
      .up(inp_up),
      .down(inp_down),
      .left(inp_left),
      .right(inp_right),
      .a(inp_a),
      .x(inp_x),
      .l(inp_l),
      .r(inp_r)
  );

  // --------------------------------------------------------------------------
  // Colors
  // --------------------------------------------------------------------------
  localparam [5:0] BLACK = {2'b00, 2'b00, 2'b00};
  localparam [5:0] GREEN = {2'b00, 2'b11, 2'b00};
  localparam [5:0] WHITE = {2'b11, 2'b11, 2'b11};

  // --------------------------------------------------------------------------
  // Tile glyphs (8x8)
  // --------------------------------------------------------------------------
  
  localparam [7:0] [0:7] COVER_TILE = {
      8'b01111110,
      8'b10000001,
      8'b10000001,
      8'b10000001,
      8'b10000001,
      8'b10000001,
      8'b10000001,
      8'b01111110
  };

  localparam [7:0] [0:7] EMTRY_TILE = {
      8'b01111110,
      8'b11111111,
      8'b11111111,
      8'b11111111,
      8'b11111111,
      8'b11111111,
      8'b11111111,
      8'b01111110
  };

  localparam [7:0] [0:7] MINES_TILE = {
      8'b10011001,
      8'b01111110,
      8'b01100110,
      8'b11011011,
      8'b11011011,
      8'b01100110,
      8'b01111110,
      8'b10011001
  };

  localparam [7:0] [0:7] ONES_TILE = {
      8'b01111110,
      8'b11110111,
      8'b11100111,
      8'b11010111,
      8'b11110111,
      8'b11110111,
      8'b11000011,
      8'b01111110
  };

  localparam [7:0] [0:7] TWOS_TILE = {
      8'b01111110,
      8'b11100111,
      8'b11011011,
      8'b11111011,
      8'b11100111,
      8'b11011111,
      8'b11000011,
      8'b01111110
  };

  localparam [7:0] [0:7] THREE_TILE = {
      8'b01111110,
      8'b11100111,
      8'b11011011,
      8'b11111011,
      8'b11100111,
      8'b11111011,
      8'b11100111,
      8'b01111110
  };

  // --------------------------------------------------------------------------
  // Timer glyphs (8x8)
  // --------------------------------------------------------------------------
  localparam [7:0] [0:7] ZERO_TIME = {
      8'b00111100, 8'b01100110, 8'b01101110, 8'b01110110,
      8'b01100110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] ONE_TIME = {
      8'b00011000, 8'b00111000, 8'b00011000, 8'b00011000,
      8'b00011000, 8'b00011000, 8'b01111110, 8'b00000000
  };

  localparam [7:0] [0:7] TWO_TIME = {
      8'b00111100, 8'b01100110, 8'b00000110, 8'b00001100,
      8'b00110000, 8'b01100000, 8'b01111110, 8'b00000000
  };

  localparam [7:0] [0:7] THREE_TIME = {
      8'b00111100, 8'b01100110, 8'b00000110, 8'b00011100,
      8'b00000110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] FOUR_TIME = {
      8'b00001100, 8'b00011100, 8'b00111100, 8'b01101100,
      8'b01111110, 8'b00001100, 8'b00001100, 8'b00000000
  };

  localparam [7:0] [0:7] FIVE_TIME = {
      8'b01111110, 8'b01100000, 8'b01100000, 8'b01111100,
      8'b00000110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] SIX_TIME = {
      8'b00111100, 8'b01100110, 8'b01100000, 8'b01111100,
      8'b01100110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] SEVEN_TIME = {
      8'b01111110, 8'b00000110, 8'b00001100, 8'b00011000,
      8'b00110000, 8'b00110000, 8'b00110000, 8'b00000000
  };

  localparam [7:0] [0:7] EIGHT_TIME = {
      8'b00111100, 8'b01100110, 8'b01100110, 8'b00111100,
      8'b01100110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] NINE_TIME = {
      8'b00111100, 8'b01100110, 8'b01100110, 8'b00111110,
      8'b00000110, 8'b01100110, 8'b00111100, 8'b00000000
  };

  // --------------------------------------------------------------------------
  // Character glyphs (8x8)
  // --------------------------------------------------------------------------
  localparam [7:0] [0:7] GLYPH_A = {
      8'b00011000, 8'b00100100, 8'b01000010, 8'b01111110,
      8'b01000010, 8'b01000010, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_B = {
      8'b01111100, 8'b01000010, 8'b01000010, 8'b01111100,
      8'b01000010, 8'b01000010, 8'b01111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_E = {
      8'b01111110, 8'b01000000, 8'b01000000, 8'b01111100,
      8'b01000000, 8'b01000000, 8'b01111110, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_G = {
      8'b00111100, 8'b01000010, 8'b01000000, 8'b01001110,
      8'b01000010, 8'b01000010, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_H = {
      8'b01000010, 8'b01000010, 8'b01000010, 8'b01111110,
      8'b01000010, 8'b01000010, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_I = {
      8'b00111100, 8'b00011000, 8'b00011000, 8'b00011000,
      8'b00011000, 8'b00011000, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_L = {
      8'b01000000, 8'b01000000, 8'b01000000, 8'b01000000,
      8'b01000000, 8'b01000000, 8'b01111110, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_M = {
      8'b01000010, 8'b01100110, 8'b01011010, 8'b01011010,
      8'b01000010, 8'b01000010, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_N = {
      8'b01000010, 8'b01100010, 8'b01010010, 8'b01001010,
      8'b01000110, 8'b01000010, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_O = {
      8'b00111100, 8'b01000010, 8'b01000010, 8'b01000010,
      8'b01000010, 8'b01000010, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_P = {
      8'b01111100, 8'b01000010, 8'b01000010, 8'b01111100,
      8'b01000000, 8'b01000000, 8'b01000000, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_R = {
      8'b01111100, 8'b01000010, 8'b01000010, 8'b01111100,
      8'b01001000, 8'b01000100, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_S = {
      8'b00111100, 8'b01000010, 8'b01000000, 8'b00111100,
      8'b00000010, 8'b01000010, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_T = {
      8'b01111110, 8'b00011000, 8'b00011000, 8'b00011000,
      8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_U = {
      8'b01000010, 8'b01000010, 8'b01000010, 8'b01000010,
      8'b01000010, 8'b01000010, 8'b00111100, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_V = {
      8'b01000010, 8'b01000010, 8'b01000010, 8'b01000010,
      8'b01000010, 8'b00100100, 8'b00011000, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_W = {
      8'b01000010, 8'b01000010, 8'b01000010, 8'b01011010,
      8'b01011010, 8'b01100110, 8'b01000010, 8'b00000000
  };

  localparam [7:0] [0:7] GLYPH_Y  = {
      8'b01000010, 8'b00100100, 8'b00011000, 8'b00011000,
      8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000
  };

  // --------------------------------------------------------------------------
  // Game constants/state
  // --------------------------------------------------------------------------
  localparam [1:0] START = 2'b00;
  localparam [1:0] PLAY  = 2'b01;
  localparam [1:0] WIN   = 2'b10;
  localparam [1:0] OVER  = 2'b11;

  localparam [2:0] TILE_COVER = 3'b000;
  localparam [2:0] TILE_EMPTY = 3'b001;
  localparam [2:0] TILE_MINE  = 3'b010;
  localparam [2:0] TILE_ONE   = 3'b011;
  localparam [2:0] TILE_TWO   = 3'b100;
  localparam [2:0] TILE_THREE = 3'b101;

  localparam integer CLOCK_HZ = 25_000_000;

  localparam [9:0] GRID_X = 10'd145;
  localparam [9:0] TILE_SIZE = 10'd64;

  reg [1:0] status;

  // STATE = what player currently sees.
  reg [2:0] STATE[0:24];

  // MAP = fixed solution.
  reg [2:0] MAP[0:24];

  integer k;

  // --------------------------------------------------------------------------
  // Timer: BCD digits, avoids /10, %10, /100, %100 hardware
  // --------------------------------------------------------------------------
  reg [24:0] second_counter;
  reg [3:0] timer_hundreds;
  reg [3:0] timer_tens;
  reg [3:0] timer_ones;

  // --------------------------------------------------------------------------
  // Cursor / edge detection
  // NOTE: row 0 is bottom row, row 4 is top row to preserve your original map.
  // --------------------------------------------------------------------------
  reg [2:0] cursor_row;
  reg [2:0] cursor_col;

  reg prev_up;
  reg prev_down;
  reg prev_left;
  reg prev_right;
  reg prev_start;

  reg [4:0] tile_left;

  wire up_pressed    = inp_up    & ~prev_up;
  wire down_pressed  = inp_down  & ~prev_down;
  wire left_pressed  = inp_left  & ~prev_left;
  wire right_pressed = inp_right & ~prev_right;
  wire start_pressed = inp_start & ~prev_start;

  // Cursor coordinates are lookup-based: no multiplication by 69.
  reg [9:0] cursor_x;
  reg [9:0] cursor_y;

  always @(*) begin
    case (cursor_col)
      3'd0: cursor_x = 10'd145;
      3'd1: cursor_x = 10'd214;
      3'd2: cursor_x = 10'd283;
      3'd3: cursor_x = 10'd352;
      3'd4: cursor_x = 10'd421;
      default: cursor_x = 10'd145;
    endcase

    case (cursor_row)
      3'd0: cursor_y = 10'd411;
      3'd1: cursor_y = 10'd342;
      3'd2: cursor_y = 10'd273;
      3'd3: cursor_y = 10'd204;
      3'd4: cursor_y = 10'd135;
      default: cursor_y = 10'd411;
    endcase
  end

  wire cursor_active =
      (pix_x >= cursor_x) &&
      (pix_x <  cursor_x + 10'd64) &&
      (pix_y >= cursor_y) &&
      (pix_y <  cursor_y + 10'd64);

  // --------------------------------------------------------------------------
  // Rendering wires
  // --------------------------------------------------------------------------
  wire tile = tile_state_active(0);

  wire timer_digit_1 = digit_active(10'd50,  10'd10, timer_hundreds);
  wire timer_digit_2 = digit_active(10'd120, 10'd10, timer_tens);
  wire timer_digit_3 = digit_active(10'd190, 10'd10, timer_ones);
  wire timer_active = timer_digit_1 | timer_digit_2 | timer_digit_3;

  wire counter_mine =
      glyph_active(10'd500, 10'd10, MINES_TILE) | digit_active(10'd570, 10'd15, 4'd3);

  wire selected_tile_active = tile & cursor_active;
  wire play_active = tile | timer_active | counter_mine;

  wire home_title       = home_title_active(0);
  wire push_start_text  = push_start_active(0);
  wire home_mine        = glyph_active(10'd288, 10'd180, MINES_TILE);
  wire home_active      = home_title | home_mine | push_start_text;

  wire win_title        = win_title_active(0);
  wire win_active       = win_title | push_start_text;

  wire gameover_title   = gameover_title_active(0);
  wire gameover_mine    = glyph_active(10'd288, 10'd210, MINES_TILE);
  wire gameover_active  = gameover_title | gameover_mine | push_start_text;

  // --------------------------------------------------------------------------
  // Game logic
  // --------------------------------------------------------------------------
  always @(posedge clk) begin
    if (~rst_n) begin
      status <= START;

      second_counter  <= 25'd0;
      timer_hundreds  <= 4'd0;
      timer_tens      <= 4'd0;
      timer_ones      <= 4'd0;

      cursor_row <= 3'd0;
      cursor_col <= 3'd0;

      prev_up    <= 1'b0;
      prev_down  <= 1'b0;
      prev_left  <= 1'b0;
      prev_right <= 1'b0;
      prev_start <= 1'b0;

      tile_left <= 5'd22;

      for (k = 0; k < 25; k = k + 1)
        STATE[k] <= TILE_COVER;

      // Fixed 5x5 map (same ordering as your original code)
      MAP[0]  <= 3'b001; MAP[1]  <= 3'b011; MAP[2]  <= 3'b011; MAP[3]  <= 3'b100; MAP[4]  <= 3'b010;
      MAP[5]  <= 3'b001; MAP[6]  <= 3'b011; MAP[7]  <= 3'b010; MAP[8]  <= 3'b100; MAP[9]  <= 3'b011;
      MAP[10] <= 3'b001; MAP[11] <= 3'b011; MAP[12] <= 3'b100; MAP[13] <= 3'b100; MAP[14] <= 3'b011;
      MAP[15] <= 3'b001; MAP[16] <= 3'b001; MAP[17] <= 3'b011; MAP[18] <= 3'b010; MAP[19] <= 3'b011;
      MAP[20] <= 3'b001; MAP[21] <= 3'b001; MAP[22] <= 3'b011; MAP[23] <= 3'b011; MAP[24] <= 3'b011;

    end else begin
      // Always update previous button levels so presses are one-clock events.
      prev_up    <= inp_up;
      prev_down  <= inp_down;
      prev_left  <= inp_left;
      prev_right <= inp_right;
      prev_start <= inp_start;

      case (status)

        START: begin
          if (start_pressed) begin
            status <= PLAY;
            second_counter <= 25'd0;
            timer_hundreds <= 4'd0;
            timer_tens <= 4'd0;
            timer_ones <= 4'd0;
            tile_left <= 5'd22;
            cursor_row <= 3'd0;
            cursor_col <= 3'd0;

            for (k = 0; k < 25; k = k + 1)
              STATE[k] <= TILE_COVER;
          end
        end

        PLAY: begin
          // Movement: row 0 is bottom, so UP increases row.
          if (up_pressed && cursor_row < 4)
            cursor_row <= cursor_row + 1'b1;

          if (down_pressed && cursor_row > 0)
            cursor_row <= cursor_row - 1'b1;

          if (left_pressed && cursor_col > 0)
            cursor_col <= cursor_col - 1'b1;

          if (right_pressed && cursor_col < 4)
            cursor_col <= cursor_col + 1'b1;

          // Open a tile with A.
          // STATE != MAP prevents decrementing tile_left repeatedly.
          if (inp_a && (STATE[cursor_row*5 + cursor_col] != MAP[cursor_row*5 + cursor_col])) begin
            if (MAP[cursor_row*5 + cursor_col] == TILE_MINE) begin
              status <= OVER;

              for (k = 0; k < 25; k = k + 1)
                STATE[k] <= MAP[k];

            end else begin
              STATE[cursor_row*5 + cursor_col] <= MAP[cursor_row*5 + cursor_col];

              if (tile_left > 0)
                tile_left <= tile_left - 1'b1;

              // Immediate win on the final safe tile.
              if (tile_left == 1)
                status <= WIN;
            end
          end

          // 1-second timer, saturates at 999.
          if (second_counter == CLOCK_HZ - 1) begin
            second_counter <= 25'd0;

            if (!((timer_hundreds == 9) &&
                  (timer_tens == 9) &&
                  (timer_ones == 9))) begin

              if (timer_ones < 9) begin
                timer_ones <= timer_ones + 1'b1;
              end else begin
                timer_ones <= 4'd0;

                if (timer_tens < 9) begin
                  timer_tens <= timer_tens + 1'b1;
                end else begin
                  timer_tens <= 4'd0;
                  timer_hundreds <= timer_hundreds + 1'b1;
                end
              end
            end
          end else begin
            second_counter <= second_counter + 1'b1;
          end
        end

        WIN: begin
          if (start_pressed) begin
            status <= PLAY;
            second_counter <= 25'd0;
            timer_hundreds <= 4'd0;
            timer_tens <= 4'd0;
            timer_ones <= 4'd0;
            tile_left <= 5'd22;
            cursor_row <= 3'd0;
            cursor_col <= 3'd0;

            for (k = 0; k < 25; k = k + 1)
              STATE[k] <= TILE_COVER;
          end
        end

        OVER: begin
          if (start_pressed) begin
            status <= PLAY;
            second_counter <= 25'd0;
            timer_hundreds <= 4'd0;
            timer_tens <= 4'd0;
            timer_ones <= 4'd0;
            tile_left <= 5'd22;
            cursor_row <= 3'd0;
            cursor_col <= 3'd0;

            for (k = 0; k < 25; k = k + 1)
              STATE[k] <= TILE_COVER;
          end
        end

        default: begin
          status <= START;
        end
      endcase
    end
  end

  // --------------------------------------------------------------------------
  // VGA RGB register
  // --------------------------------------------------------------------------
  always @(posedge clk) begin
    if (~rst_n) begin
      {R, G, B} <= BLACK;
    end else if (!video_active) begin
      {R, G, B} <= BLACK;
    end else begin
      case (status)
        START: begin
          {R, G, B} <= home_active ? GREEN : BLACK;
        end

        PLAY: begin
          if (selected_tile_active)
            {R, G, B} <= GREEN;
          else if (play_active)
            {R, G, B} <= WHITE;
          else
            {R, G, B} <= BLACK;
        end

        WIN: begin
          if (win_title)
            {R, G, B} <= GREEN;
          else if (push_start_text)
            {R, G, B} <= WHITE;
          else
            {R, G, B} <= BLACK;
        end

        OVER: begin
          {R, G, B} <= gameover_active ? WHITE : BLACK;
        end

        default: begin
          {R, G, B} <= BLACK;
        end
      endcase
    end
  end

  // ==========================================================================
  // FUNCTIONS
  // ==========================================================================

  // --------------------------------------------------------------------------
  // Generic 64x64 scaled 8x8 glyph
  // --------------------------------------------------------------------------
  function glyph_active;
    input [9:0] x0;
    input [9:0] y0;
    input [7:0] [0:7] glyph;

    reg [2:0] gx;
    reg [2:0] gy;
    reg [7:0] glyph_row;

    begin
      glyph_active = 1'b0;

      if ((pix_x >= x0) && (pix_x < x0 + 10'd64) &&
          (pix_y >= y0) && (pix_y < y0 + 10'd64)) begin

        gx = (pix_x - x0) >> 3;
        gy = (pix_y - y0) >> 3;

        // The first row in a [7:0][0:7] glyph constant is stored at index 7.
        // Reverse the lookup so the first written row appears at the top.
        glyph_row = glyph[3'd7 - gy];
        glyph_active = glyph_row[7-gx];
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // Optimized 5x5 tile renderer.
  // No nested 25-cell loop.
  // --------------------------------------------------------------------------
  function tile_state_active;
    input  y0;
    reg [2:0] col;
    reg [2:0] row_idx;
    reg [9:0] tile_x;
    reg [9:0] tile_y;
    reg [6:0] local_x;
    reg [6:0] local_y;
    reg [2:0] tile_type;
    reg [7:0] glyph_row;

    begin
      tile_state_active = 1'b0;
      col = 0;
      row_idx = 0;
      tile_x = 0;
      tile_y = 0;
      local_x = 0;
      local_y = 0;
      tile_type = TILE_COVER;
      glyph_row = 0;

      // First identify horizontal cell.
      if ((pix_x >= 145) && (pix_x < 490) &&
          (pix_y >= 135) && (pix_y < 475)) begin

        if      (pix_x >= 421) begin col = 4; tile_x = 421; end
        else if (pix_x >= 352) begin col = 3; tile_x = 352; end
        else if (pix_x >= 283) begin col = 2; tile_x = 283; end
        else if (pix_x >= 214) begin col = 1; tile_x = 214; end
        else                   begin col = 0; tile_x = 145; end

        // Preserve original orientation: row 0 is bottom.
        if      (pix_y >= 411) begin row_idx = 0; tile_y = 411; end
        else if (pix_y >= 342) begin row_idx = 1; tile_y = 342; end
        else if (pix_y >= 273) begin row_idx = 2; tile_y = 273; end
        else if (pix_y >= 204) begin row_idx = 3; tile_y = 204; end
        else                   begin row_idx = 4; tile_y = 135; end

        local_x = pix_x - tile_x;
        local_y = pix_y - tile_y;

        // 64-pixel tile, 5-pixel gap.
        if ((local_x < 64) && (local_y < 64)) begin
          tile_type = STATE[row_idx*5 + col];

          case (tile_type)
            TILE_COVER: glyph_row = COVER_TILE[3'd7 - local_y[5:3]];
            TILE_EMPTY: glyph_row = EMTRY_TILE[3'd7 - local_y[5:3]];
            TILE_MINE : glyph_row = MINES_TILE[3'd7 - local_y[5:3]];
            TILE_ONE  : glyph_row = ONES_TILE[3'd7 - local_y[5:3]];
            TILE_TWO  : glyph_row = TWOS_TILE[3'd7 - local_y[5:3]];
            TILE_THREE: glyph_row = THREE_TILE[3'd7 - local_y[5:3]];
            default   : glyph_row = COVER_TILE[3'd7 - local_y[5:3]];
          endcase

          tile_state_active = glyph_row[7-local_x[5:3]];
        end
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // Timer digit renderer (64x64)
  // --------------------------------------------------------------------------
  function digit_active;
    input [9:0] x0;
    input [9:0] y0;
    input [3:0] digit;

    reg [2:0] gx;
    reg [2:0] gy;
    reg [7:0] glyph_row;

    begin
      digit_active = 1'b0;
      glyph_row = 0;

      if ((pix_x >= x0) && (pix_x < x0 + 10'd64) &&
          (pix_y >= y0) && (pix_y < y0 + 10'd64)) begin

        gx = (pix_x - x0) >> 3;
        gy = (pix_y - y0) >> 3;

        case (digit)
          4'd0: glyph_row = ZERO_TIME[3'd7 - gy];
          4'd1: glyph_row = ONE_TIME[3'd7 - gy];
          4'd2: glyph_row = TWO_TIME[3'd7 - gy];
          4'd3: glyph_row = THREE_TIME[3'd7 - gy];
          4'd4: glyph_row = FOUR_TIME[3'd7 - gy];
          4'd5: glyph_row = FIVE_TIME[3'd7 - gy];
          4'd6: glyph_row = SIX_TIME[3'd7 - gy];
          4'd7: glyph_row = SEVEN_TIME[3'd7 - gy];
          4'd8: glyph_row = EIGHT_TIME[3'd7 - gy];
          4'd9: glyph_row = NINE_TIME[3'd7 - gy];
          default: glyph_row = 8'b0;
        endcase

        digit_active = glyph_row[7-gx];
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // Shared font decoder.
  // Both 32x32 and 16x16 text use this ONE decoder function.
  // --------------------------------------------------------------------------
  function [7:0] font_row;
    input [7:0] character;
    input [2:0] row_index;

    begin
      case (character)
        "A": font_row = GLYPH_A[3'd7 - row_index];
        "B": font_row = GLYPH_B[3'd7 - row_index];
        "E": font_row = GLYPH_E[3'd7 - row_index];
        "G": font_row = GLYPH_G[3'd7 - row_index];
        "H": font_row = GLYPH_H[3'd7 - row_index];
        "I": font_row = GLYPH_I[3'd7 - row_index];
        "L": font_row = GLYPH_L[3'd7 - row_index];
        "M": font_row = GLYPH_M[3'd7 - row_index];
        "N": font_row = GLYPH_N[3'd7 - row_index];
        "O": font_row = GLYPH_O[3'd7 - row_index];
        "P": font_row = GLYPH_P[3'd7 - row_index];
        "R": font_row = GLYPH_R[3'd7 - row_index];
        "S": font_row = GLYPH_S[3'd7 - row_index];
        "T": font_row = GLYPH_T[3'd7 - row_index];
        "U": font_row = GLYPH_U[3'd7 - row_index];
        "V": font_row = GLYPH_V[3'd7 - row_index];
        "W": font_row = GLYPH_W[3'd7 - row_index];
        "Y": font_row = GLYPH_Y[3'd7 - row_index];
        default: font_row = 8'b00000000;
      endcase
    end
  endfunction

  // 32x32 character.
  function char32_active;
    input [9:0] x0;
    input [9:0] y0;
    input [7:0] character;

    reg [2:0] gx;
    reg [2:0] gy;
    reg [7:0] glyph_row;

    begin
      char32_active = 1'b0;

      if ((pix_x >= x0) && (pix_x < x0 + 10'd32) &&
          (pix_y >= y0) && (pix_y < y0 + 10'd32)) begin

        gx = (pix_x - x0) >> 2;
        gy = (pix_y - y0) >> 2;
        glyph_row = font_row(character, gy);

        char32_active = glyph_row[7-gx];
      end
    end
  endfunction

  // 16x16 character.
  function char16_active;
    input [9:0] x0;
    input [9:0] y0;
    input [7:0] character;

    reg [2:0] gx;
    reg [2:0] gy;
    reg [7:0] glyph_row;

    begin
      char16_active = 1'b0;

      if ((pix_x >= x0) && (pix_x < x0 + 10'd16) &&
          (pix_y >= y0) && (pix_y < y0 + 10'd16)) begin

        gx = (pix_x - x0) >> 1;
        gy = (pix_y - y0) >> 1;
        glyph_row = font_row(character, gy);

        char16_active = glyph_row[7-gx];
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // HOME title: "MINESWEEPER"
  // Uses only one selected character per pixel instead of ORing 11 renderers.
  // --------------------------------------------------------------------------
  function home_title_active;
    input [9:0] y0;
    reg [7:0] ch;
    reg [9:0] x0;

    begin
      home_title_active = 1'b0;
      ch = 8'h20;
      x0 = 0;

      if ((pix_y >= 100) && (pix_y < 132)) begin
        if      ((pix_x >= 135) && (pix_x < 167)) begin ch = "M"; x0 = 135; end
        else if ((pix_x >= 171) && (pix_x < 203)) begin ch = "I"; x0 = 171; end
        else if ((pix_x >= 207) && (pix_x < 239)) begin ch = "N"; x0 = 207; end
        else if ((pix_x >= 243) && (pix_x < 275)) begin ch = "E"; x0 = 243; end
        else if ((pix_x >= 279) && (pix_x < 311)) begin ch = "S"; x0 = 279; end
        else if ((pix_x >= 315) && (pix_x < 347)) begin ch = "W"; x0 = 315; end
        else if ((pix_x >= 351) && (pix_x < 383)) begin ch = "E"; x0 = 351; end
        else if ((pix_x >= 387) && (pix_x < 419)) begin ch = "E"; x0 = 387; end
        else if ((pix_x >= 423) && (pix_x < 455)) begin ch = "P"; x0 = 423; end
        else if ((pix_x >= 459) && (pix_x < 491)) begin ch = "E"; x0 = 459; end
        else if ((pix_x >= 495) && (pix_x < 527)) begin ch = "R"; x0 = 495; end

        if (ch != 8'h20)
          home_title_active = char32_active(x0, 10'd100, ch);
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // WIN title: "YOU WIN"
  // --------------------------------------------------------------------------
  function win_title_active;
    input [9:0] y0;
    reg [7:0] ch;
    reg [9:0] x0;

    begin
      win_title_active = 1'b0;
      ch = 8'h20;
      x0 = 0;

      if ((pix_y >= 120) && (pix_y < 152)) begin
        if      ((pix_x >= 190) && (pix_x < 222)) begin ch = "Y"; x0 = 190; end
        else if ((pix_x >= 226) && (pix_x < 258)) begin ch = "O"; x0 = 226; end
        else if ((pix_x >= 262) && (pix_x < 294)) begin ch = "U"; x0 = 262; end
        else if ((pix_x >= 334) && (pix_x < 366)) begin ch = "W"; x0 = 334; end
        else if ((pix_x >= 370) && (pix_x < 402)) begin ch = "I"; x0 = 370; end
        else if ((pix_x >= 406) && (pix_x < 438)) begin ch = "N"; x0 = 406; end

        if (ch != 8'h20)
          win_title_active = char32_active(x0, 10'd120, ch);
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // GAME OVER title
  // --------------------------------------------------------------------------
  function gameover_title_active;
    input [9:0] y0;
    reg [7:0] ch;
    reg [9:0] x0;

    begin
      gameover_title_active = 1'b0;
      ch = 8'h20;
      x0 = 0;

      if ((pix_y >= 120) && (pix_y < 152)) begin
        if      ((pix_x >= 150) && (pix_x < 182)) begin ch = "G"; x0 = 150; end
        else if ((pix_x >= 186) && (pix_x < 218)) begin ch = "A"; x0 = 186; end
        else if ((pix_x >= 222) && (pix_x < 254)) begin ch = "M"; x0 = 222; end
        else if ((pix_x >= 258) && (pix_x < 290)) begin ch = "E"; x0 = 258; end
        else if ((pix_x >= 330) && (pix_x < 362)) begin ch = "O"; x0 = 330; end
        else if ((pix_x >= 366) && (pix_x < 398)) begin ch = "V"; x0 = 366; end
        else if ((pix_x >= 402) && (pix_x < 434)) begin ch = "E"; x0 = 402; end
        else if ((pix_x >= 438) && (pix_x < 470)) begin ch = "R"; x0 = 438; end

        if (ch != 8'h20)
          gameover_title_active = char32_active(x0, 10'd120, ch);
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // "PUSH START BUTTON TO PLAY" at y=330.
  // One selected glyph per current pixel.
  // --------------------------------------------------------------------------
  function push_start_active;
    input [9:0] y0;
    reg [7:0] ch;
    reg [9:0] x0;

    begin
      push_start_active = 1'b0;
      ch = 8'h20;
      x0 = 0;

      if ((pix_y >= 330) && (pix_y < 346)) begin
        // PUSH
        if      ((pix_x >= 100) && (pix_x < 116)) begin ch = "P"; x0 = 100; end
        else if ((pix_x >= 118) && (pix_x < 134)) begin ch = "U"; x0 = 118; end
        else if ((pix_x >= 136) && (pix_x < 152)) begin ch = "S"; x0 = 136; end
        else if ((pix_x >= 154) && (pix_x < 170)) begin ch = "H"; x0 = 154; end

        // START
        else if ((pix_x >= 190) && (pix_x < 206)) begin ch = "S"; x0 = 190; end
        else if ((pix_x >= 208) && (pix_x < 224)) begin ch = "T"; x0 = 208; end
        else if ((pix_x >= 226) && (pix_x < 242)) begin ch = "A"; x0 = 226; end
        else if ((pix_x >= 244) && (pix_x < 260)) begin ch = "R"; x0 = 244; end
        else if ((pix_x >= 262) && (pix_x < 278)) begin ch = "T"; x0 = 262; end

        // BUTTON
        else if ((pix_x >= 298) && (pix_x < 314)) begin ch = "B"; x0 = 298; end
        else if ((pix_x >= 316) && (pix_x < 332)) begin ch = "U"; x0 = 316; end
        else if ((pix_x >= 334) && (pix_x < 350)) begin ch = "T"; x0 = 334; end
        else if ((pix_x >= 352) && (pix_x < 368)) begin ch = "T"; x0 = 352; end
        else if ((pix_x >= 370) && (pix_x < 386)) begin ch = "O"; x0 = 370; end
        else if ((pix_x >= 388) && (pix_x < 404)) begin ch = "N"; x0 = 388; end

        // TO
        else if ((pix_x >= 424) && (pix_x < 440)) begin ch = "T"; x0 = 424; end
        else if ((pix_x >= 442) && (pix_x < 458)) begin ch = "O"; x0 = 442; end

        // PLAY
        else if ((pix_x >= 478) && (pix_x < 494)) begin ch = "P"; x0 = 478; end
        else if ((pix_x >= 496) && (pix_x < 512)) begin ch = "L"; x0 = 496; end
        else if ((pix_x >= 514) && (pix_x < 530)) begin ch = "A"; x0 = 514; end
        else if ((pix_x >= 532) && (pix_x < 548)) begin ch = "Y"; x0 = 532; end

        if (ch != 8'h20)
          push_start_active = char16_active(x0, 10'd330, ch);
      end
    end
  endfunction

endmodule

`default_nettype wire
