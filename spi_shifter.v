`timescale 1ns / 1ps

module spi_shifter(input pclk,
                   input preset_n,
                   input ss,
                   input send_data,
                   input lsbfe,
                   input cpha,
                   input cpol,
                   input miso_rcv_neg_clk,
                   input miso_rcv_pos_clk,
                   input mosi_snd_pos_clk,
                   input mosi_snd_neg_clk,
                   input [7:0] data_mosi,
                   input miso,
                   input receive_data,
                   output reg mosi,
                   output [7:0] data_miso);



           reg [7:0] shift_register;
           reg [7:0] temp_reg;
           reg [2:0] count;
           reg [2:0] count1;
           reg [2:0] count2;
           reg [2:0] count3;

           always @(posedge pclk or negedge preset_n) begin
                if(!preset_n) begin
                        shift_register <= 8'b0;
                end
                else if (send_data) begin
                        shift_register <= data_mosi;
                end
           end


           always @(posedge pclk or negedge preset_n) begin
                if(!preset_n) begin
                        mosi   <= 1'b0;
                        count  <= 3'd0;
                        count1 <= 3'd7;
                end

                else begin
                        if(!ss) begin
                                if((!cpol && cpha)||(!cpha && cpol)) begin
                                        if(lsbfe) begin
                                                if(count <= 7) begin
                                                        if(mosi_snd_neg_clk) begin
                                                                mosi <= shift_register[count];
                                                                count <= count+1'b1;
                                                        end
                                                end
                                                else begin
                                                        count <= 0;
                                                end
                                        end

                                        else begin
                                                if(count1 >= 0) begin
                                                        if(mosi_snd_neg_clk) begin
                                                                mosi <= shift_register[count1];
                                                                count1 <= count1-1'b1;
                                                        end
                                                end
                                                else begin
                                                        count1 <= 3'd7;
                                                end
                                        end
                                end

                                else begin
                                        if(lsbfe) begin
                                                if(count <= 7) begin
                                                        if(mosi_snd_pos_clk) begin
                                                                mosi <= shift_register[count];
                                                                count <= count+1'b1;
                                                        end
                                                end
                                                else begin
                                                        count <= 0;
                                                end
                                        end
                                        else begin
                                                if(count >= 0) begin
                                                        if(mosi_snd_pos_clk) begin
                                                                mosi <= shift_register[count1];
                                                                count1 <= count1-1'b1;
                                                        end
                                                end
                                                else begin
                                                        count1 <= 3'd7;
                                                end
                                        end
                                end

                        end

                end

           end


           always @(posedge pclk or negedge preset_n) begin
                if(!preset_n) begin
                        temp_reg <= 8'd0;
                        count2 <= 3'd0;
                        count3 <= 3'd7;
                end

                else begin
                        if(!ss) begin
                                if((!cpha && cpol) || (cpha && !cpol)) begin
                                        if(lsbfe) begin
                                                if(count2 <= 7) begin
                                                        if(miso_rcv_neg_clk) begin
                                                                temp_reg[count2] <= miso;
                                                                count2 <= count2+1;
                                                        end
                                                end
                                                else begin
                                                        count2 <= 0;
                                                end
                                        end
                                        else begin
                                                if(count3 >= 0) begin
                                                        if(miso_rcv_neg_clk) begin
                                                                temp_reg[count3] <= miso;
                                                                count3 <= count3-1;
                                                        end
                                                end
                                                else begin
                                                        count3 <= 3'd7;
                                                end
                                        end
                                end
                                else begin
                                        if(lsbfe) begin
                                                if(count2 <= 7) begin
                                                        if(miso_rcv_pos_clk) begin
                                                                temp_reg[count2] <= miso;
                                                                count2 <= count2+1;
                                                        end
                                                end
                                                else begin
                                                        count2 <= 0;
                                                end
                                        end
                                        else begin
                                                if(count3 >= 0) begin
                                                        if(miso_rcv_pos_clk) begin
                                                                temp_reg[count3] <= miso;
                                                                count3 <= count3-1;
                                                        end
                                                end
                                                else begin
                                                        count3 <= 3'd7;
                                                end
                                        end
                                end

                        end

                end

           end

           assign data_miso = (receive_data == 1)?temp_reg:8'b0;
endmodule
