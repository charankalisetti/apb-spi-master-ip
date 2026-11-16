module Baud_Rate_Generator(pclk,ss,P_aalreset,sppr,spr,cpol,cpha,
spiswai,spi_mode,sclk_o,BaudRateDivisor,
miso_sample_on_sclk_rising_o,miso_sample_on_sclk_falling_o,
mosi_update_on_sclk_rising_o,mosi_update_on_sclk_falling_o);
  
input pclk,ss,P_aalreset,cpha,cpol,spiswai;
input [2:0]sppr,spr;
input [1:0]spi_mode;
output [11:0]BaudRateDivisor;
// One-PCLK-cycle clock enables for the SPI shifters; these are not SCLK clocks.
// CPOL/CPHA select which edge-specific enable pulses during each SCLK period.
output sclk_o,
       miso_sample_on_sclk_rising_o,miso_sample_on_sclk_falling_o,
       mosi_update_on_sclk_rising_o,mosi_update_on_sclk_falling_o;

parameter RUN=00;WAIT=01;STOP=10;


assign BaudRateDivisor=(sppr+1)*(2**spr+1);

assign pre_sclk_o=cpol?1'b1:1'b0;

always@(posedge pclk or negedge P_aalreset)
	begin
		if(!P_aalreset)
			begin
				count<=0;
				sclk_o<=pre_sclk_o;
			end
		else if(!ss&&(RUN||WAIT)&&spiswai==0)
			begin
				if(count==((BaudRateDivisor/2)-1))
					begin	
						sclk_o<=~sclk_o;
						count<=0;
					end
				else
					count=count+1;
			end		
		else
	        begin
	            sclk_o<=pre_sclk_o;
			    count_s<=1'b0;
		    end
	end	
		

always@(posedge pclk or negedge P_aalreset)
	begin
		if(!P_aalreset)
			begin
				miso_sample_on_sclk_rising_o=0;
				miso_sample_on_sclk_falling_o=0;
			end
		// CPOL != CPHA selects SPI modes 1 and 2: MISO is sampled on
		// the falling SCLK edge. sclk_o is high just before that edge.
		else if((cpol&&!cpha)||(!cpol&&cpha))
			begin
				if(sclk_o==1)
					begin
						if(count==((BaudRateDivisor/2)-1))
							miso_sample_on_sclk_falling_o<=1;
							else
								miso_sample_on_sclk_falling_o<=0;
					end	
				else
					miso_sample_on_sclk_falling_o<=0;
		else
			miso_sample_on_sclk_falling_o<=0;
