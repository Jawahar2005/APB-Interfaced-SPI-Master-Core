`timescale 1ns / 1ps

module baud_rate_generator(pclk, preset_n, spi_swai, spi_mode, cpol, cpha, sppr, spr, ss, sclk, miso_rcv_neg_clk, miso_rcv_pos_clk, mosi_snd_neg_clk, mosi_snd_pos_clk, baud_rate_divisor);

        input pclk;
        input preset_n;
        input spi_swai;
        input [1:0] spi_mode;
        input cpol;
        input cpha;
        input [2:0] sppr;
        input [2:0] spr;
        input ss;

        output reg sclk;
        output reg miso_rcv_neg_clk;
        output reg miso_rcv_pos_clk;
        output reg mosi_snd_pos_clk;
        output reg mosi_snd_neg_clk;
        output [11:0] baud_rate_divisor;

        wire pre_sclk;
        reg [11:0] count;

        assign baud_rate_divisor = (sppr+1)*(2**(spr+1));
        assign pre_sclk = cpol;

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n) begin
                        sclk  <= pre_sclk;
                        count <= 12'hfff;
                end

                else if ((spi_mode == 2'b00 || (spi_mode == 2'b01 && spi_swai == 1'b0)) && !ss) begin
                        if(((baud_rate_divisor/2) -1) == count) begin
                                sclk  <= ~sclk;
                                count <= 12'b0;
                        end
                        else begin
                                sclk  <= sclk;
                                count <= count+1'b1;
                        end
                end
                else begin
                        sclk  <= pre_sclk;
                        count <= 12'hfff;
                end
        end

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n) begin
                        miso_rcv_pos_clk <= 1'b0;
                        miso_rcv_neg_clk <= 1'b0;
                end

                else if((cpol && cpha) || (!cpol && !cpha)) begin
                        if (sclk == 0) begin
                                if(((baud_rate_divisor/2)-1) == count) begin
                                        miso_rcv_pos_clk <= 1'b1;
                                        miso_rcv_neg_clk <= 1'b0; //if at next edge cpol and cpha change then pos wont go to zero.
                                end
                                else begin
                                        miso_rcv_pos_clk <= 1'b0;
                                        miso_rcv_neg_clk <= 1'b0; //
                                end
                        end
                        else begin
                                miso_rcv_pos_clk <= 1'b0;
                                miso_rcv_neg_clk <= 1'b0; //
                        end

                end

                else if((cpol && !cpha) || (!cpol && cpha)) begin
                        if(sclk == 1) begin
                                if(((baud_rate_divisor/2)-1) == count) begin
                                        miso_rcv_neg_clk <= 1'b1;
                                        miso_rcv_pos_clk <= 1'b0; //
                                end
                                else begin
                                        miso_rcv_neg_clk <= 1'b0;
                                        miso_rcv_pos_clk <= 1'b0; //
                                end
                        end
                        else begin
                                miso_rcv_neg_clk <= 1'b0;
                                miso_rcv_pos_clk <= 1'b0; //
                        end
                end
                else begin
                        miso_rcv_neg_clk <= 1'b0;
                        miso_rcv_pos_clk <= 1'b0;
                end
        end

        always @(posedge pclk or negedge preset_n)
        begin
                if(!preset_n) begin
                        mosi_snd_pos_clk <= 1'b0;
                        mosi_snd_neg_clk <= 1'b0;
                end

                else if((cpol && cpha) || (!cpol && !cpha)) begin
                        if(sclk == 0) begin
                                if(((baud_rate_divisor/2)-2) == count) begin
                                        mosi_snd_pos_clk <= 1'b1;
                                        mosi_snd_neg_clk <= 1'b0; //
                                end
                                else begin
                                        mosi_snd_pos_clk <= 1'b0;
                                        mosi_snd_neg_clk <= 1'b0; //
                                end
                        end
                        else begin
                                mosi_snd_pos_clk <= 1'b0;
                                mosi_snd_neg_clk <= 1'b0; //
                        end
                end

                else if((cpol && !cpha) || (!cpol && cpha)) begin
                        if(sclk == 1) begin
                                if(((baud_rate_divisor/2)-2) == count) begin
                                        mosi_snd_neg_clk <= 1'b1;
                                        mosi_snd_pos_clk <= 1'b0; //
                                end
                                else begin
                                        mosi_snd_neg_clk <= 1'b0;
                                        mosi_snd_pos_clk <= 1'b0; //
                                end
                        end
                        else begin
                                mosi_snd_neg_clk <= 1'b0;
                                mosi_snd_pos_clk <= 1'b0;
                        end
                end
                else begin
                        mosi_snd_neg_clk <= 1'b0;
                        mosi_snd_pos_clk <= 1'b0;
                end
        end


endmodule
