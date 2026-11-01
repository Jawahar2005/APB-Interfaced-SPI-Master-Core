`timescale 1ns / 1ps

module spi_slave_select(input pclk,
                        input preset_n,
                        input mstr,
                        input send_data,
                        input [1:0] spi_mode,
                        input spi_swai,
                        input [11:0] baud_rate_divisor,
                        output reg ss,
                        output tip,
                        output reg receive_data);

                wire [15:0] target;
                reg [15:0] count;
                reg rcv;

                assign target = 8 * baud_rate_divisor;
                assign tip = ~ss;

                always @(posedge pclk or negedge preset_n) begin
                        if(!preset_n) begin
                                ss    <= 1'b1;
                                rcv   <= 1'b0;
                                count <= 16'hffff;
                        end
                        else if (mstr && ((spi_mode == 2'b0)||(spi_mode == 2'b01 && spi_swai == 1'b0))) begin
                                if(send_data) begin
                                        ss    <= 1'b0;
                                        count <= 16'b0;
                                        rcv   <= 1'b0;
                                end
                                else if(count <= target - 1'b1) begin
                                        ss    <= 1'b0;
                                        count <= count+1'b1;

                                        if(target-1'b1 == count) begin
                                                rcv <= 1'b1;
                                        end
                                        else begin
                                                rcv <= 1'b0;
                                        end
                                end

                                else begin
                                        ss    <= 1'b1;
                                        rcv   <= 1'b0;
                                        count <= 16'hffff;
                                end
                        end
                        else begin
                                ss    <= 1'b1;
                                rcv   <= 1'b0;
                                count <= 16'hffff;
                        end
                end

                always @(posedge pclk  or negedge preset_n) begin
                        if(!preset_n) begin
                                receive_data <= 1'b0;
                        end
                        else begin
                                receive_data <= rcv;
                        end
                end

endmodule
