

module Baud_Rate_Generator_tb;

    // Inputs to the DUT
    reg pclk;
    reg P_aalreset;
    reg ss;
    reg spiswai;
    reg cpol;
    reg cpha;
    reg [2:0] sppr;
    reg [2:0] spr;
    reg [1:0] spi_mode_i;

    // Outputs from the DUT
    wire sclk_o;
    wire [11:0] BaudRateDivisor;
    wire miso_sample_on_sclk_rising_o;
    wire miso_sample_on_sclk_falling_o;
    wire mosi_update_on_sclk_rising_o;
    wire mosi_update_on_sclk_falling_o;

    // Instantiate the Unit Under Test (UUT)
    Baud_Rate_Generator_block uut (
        .pclk(pclk),
        .ss(ss),
        .P_aalreset(P_aalreset),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .spiswai(spiswai),
        .spi_mode_i(spi_mode_i),
        .sclk_o(sclk_o),
        .BaudRateDivisor(BaudRateDivisor),
        .miso_sample_on_sclk_rising_o(miso_sample_on_sclk_rising_o),
        .miso_sample_on_sclk_falling_o(miso_sample_on_sclk_falling_o),
        .mosi_update_on_sclk_rising_o(mosi_update_on_sclk_rising_o),
        .mosi_update_on_sclk_falling_o(mosi_update_on_sclk_falling_o)
    );

    // Generate the PCLK system clock. Period = 20 ns (50 MHz).
    initial begin
        pclk = 1'b0;
        forever #5 pclk = ~pclk;
    end

    // Initialize all DUT inputs.
    task initialize_inputs;
        begin
			pclk=0;
            P_aalreset = 1'b1;
            ss = 1'b1;          // Active-low select: 1 means not selected.
            spiswai = 1'b0;
            cpol = 1'b0;
            cpha = 1'b0;
            sppr = 3'b001;
            spr = 3'b001;
            spi_mode_i = 2'b01;   // RUN
        end
    endtask

    // Apply active-low reset.
    task reset_dut;
        begin
            @(negedge pclk);
            P_aalreset = 1'b0;
             @(negedge pclk);
            P_aalreset = 1'b1;
           
        end
    endtask

    // Select the peripheral and run one CPOL/CPHA combination.
    task run_spi_mode;
        input mode_cpol;
        input mode_cpha;
        begin
            @(negedge pclk);
            cpol = mode_cpol;
            cpha = mode_cpha;
            spi_mode_i = 2'b00;  // RUN
            spiswai = 1'b0;
            ss = 1'b0;         // Select the peripheral.
        end
    endtask

    // Apply reset, then exercise SPI modes 0, 1, 2, and 3.
    initial begin
        initialize_inputs;
        reset_dut;

        run_spi_mode(1'b0, 1'b0); // Mode 0
        run_spi_mode(1'b0, 1'b1); // Mode 1
        run_spi_mode(1'b1, 1'b0); // Mode 2
        run_spi_mode(1'b1, 1'b1); // Mode 3

        #2000;
        $finish;
    end

endmodule
