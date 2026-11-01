`timescale 1ns / 1ps

module top(input pclk,
         input preset_n,
         input psel,
         input penable,
         input pwrite,
         input [7:0] pwdata,
         input [2:0] paddr,
         input miso,
         output [7:0] prdata,
         output pslverr,
         output pready,
         output ss,
         output sclk,
         output spi_interrupt_request,
         output mosi);

             wire send_data;
             wire lsbfe;
             wire cpha;
             wire cpol;
             wire miso_rcv_pos_clk;
             wire miso_rcv_neg_clk;
             wire mosi_snd_pos_clk;
             wire mosi_snd_neg_clk;
             wire [7:0] data_mosi;
             wire [7:0] data_miso;
             wire spi_swai;
             wire [1:0] spi_mode;
             wire [11:0] baud_rate_divisor;
             wire mstr;
             wire tip;
             wire receive_data;
             wire [2:0] sppr;
             wire [2:0] spr;


             spi_shifter shift(.pclk(pclk),
                               .preset_n(preset_n),
                               .ss(ss),
                               .send_data(send_data),
                               .lsbfe(lsbfe),
                               .cpha(cpha),
                               .cpol(cpol),
                               .miso_rcv_neg_clk(miso_rcv_neg_clk),
                               .miso_rcv_pos_clk(miso_rcv_pos_clk),
                               .mosi_snd_pos_clk(mosi_snd_pos_clk),
                               .mosi_snd_neg_clk(mosi_snd_neg_clk),
                               .data_mosi(data_mosi),
                               .miso(miso),
                               .receive_data(receive_data),
                               .mosi(mosi),
                               .data_miso(data_miso));

              baud_rate_generator brg(.pclk(pclk),
                                      .preset_n(preset_n),
                                      .spi_swai(spi_swai),
                                      .spi_mode(spi_mode),
                                      .cpol(cpol),
                                      .cpha(cpha),
                                      .sppr(sppr),
                                      .spr(spr),
                                      .ss(ss),
                                      .sclk(sclk),
                                      .miso_rcv_neg_clk(miso_rcv_neg_clk),
                                      .miso_rcv_pos_clk(miso_rcv_pos_clk),
                                      .mosi_snd_neg_clk(mosi_snd_neg_clk),
                                      .mosi_snd_pos_clk(mosi_snd_pos_clk),
                                      .baud_rate_divisor(baud_rate_divisor));

             spi_slave_select slt(.pclk(pclk),
                                  .preset_n(preset_n),
                                  .mstr(mstr),
                                  .send_data(send_data),
                                  .spi_mode(spi_mode),
                                  .spi_swai(spi_swai),
                                  .baud_rate_divisor(baud_rate_divisor),
                                  .ss(ss),
                                  .tip(tip),
                                  .receive_data(receive_data));

              apb_slave_intf apb(.pclk(pclk),
                                 .preset_n(preset_n),
                                 .paddr(paddr),
                                 .pwrite(pwrite),
                                 .psel(psel),
                                 .penable(penable),
                                 .pwdata(pwdata),
                                 .ss(ss),
                                 .data_miso(data_miso),
                                 .receive_data(receive_data),
                                 .tip(tip),
                                 .prdata(prdata),
                                 .mstr(mstr),
                                 .cpol(cpol),
                                 .cpha(cpha),
                                 .lsbfe(lsbfe),
                                 .spi_swai(spi_swai),
                                 .sppr(sppr),
                                 .spr(spr),
                                 .spi_interrupt_request(spi_interrupt_request),
                                 .pready(pready),
                                 .pslverr(pslverr),
                                 .send_data(send_data),
                                 .data_mosi(data_mosi),
                                 .spi_mode(spi_mode));
endmodule
