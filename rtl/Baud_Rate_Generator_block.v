module Baud_Rate_Generator(pclk,ss,P_reset,sppr,spr,cpol,cpha,
spiswai,spi_mode,sclk_o,BaudRateDivisor,miso_receive_sclk,miso_receive_sclk0,
mosi_send_sclk,mosi_send_sclk0);
  
input pclk,ss,P_reset,cpha,cpol,spiswai;
input [2:0]sppr,spr;
input [1:0]spi_mode;
output [11:0]BaudRateDivisor;
output sclk_o,miso_receive_sclk,miso_receive_sclk0,
mosi_send_sclk,mosi_send_sclk0;

parameter RUN=00;WAIT=01;STOP=10;


assign BaudRateDivisor=(sppr+1)*(2**spr+1);
assign sclk_o=pclk/BaudRateDivisor;


