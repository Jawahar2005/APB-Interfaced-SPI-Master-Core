`timescale 1ns / 1ps

module top_tb();
    reg pclk;
    reg preset_n;
    reg [2:0] paddr;
    reg pwrite;
    reg [7:0] pwdata;
    reg psel;
    reg penable;
    reg miso;
    
    wire pready;
    wire pslverr;
    wire [7:0] prdata;
    wire mosi;
    wire sclk;
    wire ss;
    wire spi_interrupt_request;
    
    top DUT(.pclk(pclk),
            .preset_n(preset_n),
            .paddr(paddr),
            .pwrite(pwrite),
            .pwdata(pwdata),
            .psel(psel),
            .penable(penable),
            .miso(miso),
            .pready(pready),
            .pslverr(pslverr),
            .prdata(prdata),
            .mosi(mosi),
            .sclk(sclk),
            .ss(ss),
            .spi_interrupt_request(spi_interrupt_request));
           
     initial begin
        pclk = 1'b0;
        forever #5 pclk = ~pclk;
     end
     
     task reset();
        begin
            @(negedge pclk);
                preset_n = 1'b0;
            @(negedge pclk);
                preset_n = 1'b1;
        end
     endtask
     
     task initialize();
        begin
            preset_n = 1'b0;
            paddr    = 3'b0;
            psel     = 1'b0;
            penable  = 1'b0;
            pwrite   = 1'b0;
            pwdata   = 8'b0;
            miso     = 1'b0;
        end
     endtask
     
     task write_reg(input [7:0] data1, input [7:0] data2, input [7:0] data3);
     begin
        @(negedge pclk);
            paddr   = 3'b000;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b0;
            pwdata  = data1;
            
        @(negedge pclk);
            paddr   = 3'b000;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b1;
            pwdata  = data1;
            
        @(negedge pclk);
            wait(pready)
            penable = 1'b0;
            
        @(negedge pclk);
            paddr   = 3'b001;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b0;
            pwdata  = data2;
                
        @(negedge pclk);
            paddr   = 3'b001;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b1;
            pwdata  = data2;
            
        @(negedge pclk);
            wait(pready)
            penable = 1'b0;
            
        @(negedge pclk);
            paddr   = 3'b010;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b0;
            pwdata  = data3;
            
        @(negedge pclk);
            paddr   = 3'b010;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b1;
            pwdata  = data3;
            
        @(negedge pclk);
            wait(pready)
            penable = 1'b0;
     end    
     endtask
     
     task write_data_reg(input [7:0] data);
        begin
        @(negedge pclk);
            paddr   = 3'b101;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b0;
            pwdata  = data;
            
        @(negedge pclk);
            paddr   = 3'b101;
            pwrite  = 1'b1;
            psel    = 1'b1;
            penable = 1'b1;
            pwdata  = data;
            
        @(negedge pclk);
            wait(pready)
            penable = 1'b0;              
        end
     endtask
     
     task read_reg(input [2:0] addr);
     begin
        @(negedge pclk);
            paddr   = addr;
            pwrite  = 1'b0;
            psel    = 1'b1;
            penable = 1'b0;
           
        @(negedge pclk);
            paddr   = addr;
            pwrite  = 1'b0;
            psel    = 1'b1;
            penable = 1'b1;
            
        @(negedge pclk);
            wait(pready)
            penable = 1'b0;
     end
     endtask
       
     task miso_data_pos_lsbfe(input [7:0] data);
     integer i;
     begin
        miso = 1'bz;
        wait(~ss);
        for(i = 0;i<=7;i=i+1) begin
            @(posedge sclk);
                miso = data[i];
        end
     end
     endtask
     
    task miso_data_pos_lsbfe0(input [7:0] data);
     integer i;
     begin
        miso = 1'bz;
        wait(~ss);
        for(i = 7;i>=0;i=i-1) begin
            @(posedge sclk);
                miso = data[i];
        end
     end
     endtask
     
     task miso_data_neg_lsbfe(input [7:0] data);
      integer i;
      begin
         miso = 1'bz;
         wait(~ss);
         for(i = 0;i<=7;i=i+1) begin
             @(negedge sclk);
                 miso = data[i];
         end
      end
      endtask
      
      task miso_data_neg_lsbfe0(input [7:0] data);
       integer i;
       begin
          miso = 1'bz;
          wait(~ss);
          for(i = 7;i>=0;i=i-1) begin
              @(negedge sclk);
                  miso = data[i];
          end
       end
       endtask
     
     initial begin
        initialize();
        reset();
        write_reg(8'b1111_0001, 8'b0001_1011, 8'b0001_0001);
        write_data_reg(8'haf);
        miso_data_pos_lsbfe(8'hbf);
       // miso_data_neg_lsbfe(8'hbf); // cpol cpha 01 10
        read_reg(3'b000);
        read_reg(3'b001);
        read_reg(3'b010);
        read_reg(3'b011);
        read_reg(3'b101);
     end
     
     initial #1000 $finish;
endmodule
