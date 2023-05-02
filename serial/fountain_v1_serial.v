module fountain_v1_serial(
  input clk,
  input reset,
  input start,
  output reg done,
  input wire [63:0] data_in,
  output reg [63:0] data_out
);

  parameter N = 255; // block size
  parameter L = 10; // number of blocks to encode
  parameter K = 32; // number of non-zero coefficients

  // Linear Feedback Shift Register
  reg [63:0] lfsr;
  always @(posedge clk) begin
    if (reset) begin
      lfsr <= 8'hBC;
    end
    else begin
      lfsr <= {lfsr[62:0], lfsr[25] ^ lfsr[12] ^ lfsr[0]};
    end
  end

  // Generate matrix B
  reg [7:0] b [0:N-1][0:K-1];
  integer i, j;
  initial begin
    for (i = 0; i < N; i = i+1) begin
      for (j = 0; j < K; j = j+1) begin
        b[i][j] = lfsr;
        lfsr = {lfsr[6:0], lfsr[7] ^ lfsr[2]};
      end
    end
  end

  // Generate vector h
  reg [7:0] h [0:K-1];
  reg [7:0] data_in_reg; // new variable to store input data
  always @(posedge clk) begin
    if (start) begin
      for (i = 0; i < K; i = i+1) begin
        h[i] <= data_in_reg; // use data_in_reg instead of data_in
        data_in_reg <= data_in_reg + 1; // manipulate data_in_reg
      end
    end
  end

  // Generate vector z
  reg [7:0] z [0:N-1];
  reg [7:0] s [0:K-1];
  integer k, l, m, n;
  reg [7:0] output_reg [0:N*L-1]; // new variable to store output data
  reg [7:0] output_reg_i; // new variable to store current output byte
  integer output_index; // new variable to track output index
  always @(posedge clk) begin
    if (start) begin
      output_index = 0;
      for (k = 0; k < L; k = k+1) begin
        for (i = 0; i < N; i = i+1) begin
          z[i] = 0;
          for (j = 0; j < K; j = j+1) begin
            s[j] = h[j] ^ b[i][j];
          end
          for (l = 0; l < 8; l = l+1) begin
            for (m = 0; m < K; m = m+1) begin
              if (s[m][l] == 1) begin
                z[i][l] = z[i][l] ^ 1;
              end
            end
          end
          // Store output in output_reg
          for (n = 0; n < 8; n = n+1) begin
            output_reg[output_index][n] <= z[i][n];
          end
          output_index <= output_index + 1;
        end
      end
      done <= 1;
    end
  end
endmodule