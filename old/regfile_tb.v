// ---------- SAMPLE TEST BENCH ----------
`timescale 1 ns / 100 ps
module regfile_tb();
    // inputs to the DUT are reg type
    reg            clock, ctrl_writeEn, ctrl_reset;
    reg [4:0]     ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    reg [31:0]    data_writeReg;

    // outputs from the DUT are wire type
    wire [31:0] data_readRegA, data_readRegB;

    // Tracking the number of errors
    integer errors;
    integer index, index2;    // for testing...

    // instantiate the DUT
    regfile regfile_ut (clock, ctrl_writeEn, ctrl_reset, ctrl_writeReg,
        ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB);

    // setting the initial values of all the reg
    initial
    begin
        $display($time, " << Starting the Simulation >>");
        clock = 1'b0;    // at time 0
        errors = 0;

        $display($time, " << Power on reset >>");
        eraseByReset();
        checkAllEmpty();

        checkAllFF();
        checkAll00();

        checkBitPattern(32'hA5A5A5A5);
        checkBitPattern(32'h5A5A5A5A);

        for(index2 = 0; index2 < 100; index2 = index2 + 1) begin
            $display($time, " << Random data test %d/100 >>", index2 + 1);
            checkRandomData();
        end

        eraseByReset();
        checkAllEmpty();

        if (errors == 0) begin
            $display("The simulation completed without errors");
        end
        else begin
            $display("The simulation failed with %d errors", errors);
        end

        $stop;
    end



    // Clock generator
    always
         #10     clock = ~clock;    // toggle

    task eraseByReset;
        begin
            ctrl_reset = 1'b1;    // assert reset
            @(negedge clock);    // wait until next negative edge of clock
            @(negedge clock);    // wait until next negative edge of clock

            ctrl_reset = 1'b0;    // de-assert reset
            @(negedge clock);    // wait until next negative edge of clock
        end
    endtask

    task eraseByWrite;
        begin
            for(index = 0; index < 32; index = index + 1) begin
                writeRegister(index, 32'h00000000);
            end
        end
    endtask

    // Task for writing
    task writeRegister;

        input [4:0] writeReg;
        input [31:0] value;

        begin
            @(negedge clock);    // wait for next negedge of clock
            $display($time, " << Writing register %d with %h >>", writeReg, value);

            ctrl_writeEn = 1'b1;
            ctrl_writeReg = writeReg;
            data_writeReg = value;

            @(negedge clock); // wait for next negedge, write should be done
            ctrl_writeEn = 1'b0;
        end
    endtask

    // Task for reading
    task checkRegister;
        input [1:0] which;
        input [4:0] checkReg;
        input [31:0] exp;

        begin
            @(negedge clock);    // wait for next negedge of clock

            if (which[0] == 1'b1) begin
                ctrl_readRegA = checkReg;
            end
            if (which[1] == 1'b1) begin
                ctrl_readRegB = checkReg;
            end

            @(negedge clock); // wait for next negedge, read should be done

            if(which[0] == 1'b1) begin
                if (checkReg == 0) begin
                    if (data_readRegA !== 32'h00000000) begin
                        $display("**Error on port A: $0 should be 0 but read %h", data_readRegA, exp);
                        errors = errors + 1;
                    end
                end
                else begin
                    if (data_readRegA !== exp) begin
                        $display("**Error on port A when reading $%d: read %h but expected %h.", checkReg, data_readRegA, exp);
                        errors = errors + 1;
                    end
                end
            end
            if(which[1] == 1'b1) begin
                if (checkReg == 0) begin
                    if (data_readRegB !== 32'h00000000) begin
                        $display("**Error on port B: $0 should be 0 but read %h", data_readRegB, exp);
                        errors = errors + 1;
                    end
                end
                else begin
                    if (data_readRegB !== exp) begin
                        $display("**Error on port B when reading $%d: read %h but expected %h.", checkReg, data_readRegB, exp);
                        errors = errors + 1;
                    end
                end
            end
        end
    endtask

    task checkAllEmpty;
        begin
            $display($time, " << Checking all registers are empty from A >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(1, index, 32'h00000000);
            end
            $display($time, " << Checking all registers are empty from B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(2, index, 32'h00000000);
            end
            $display($time, " << Checking all registers are empty from A/B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(3, index, 32'h00000000);
            end
        end
    endtask

    task checkAllFF;
        begin
            $display($time, " << Checking writting all FF >>");
            for(index = 0; index < 32; index = index + 1) begin
                writeRegister(index, 32'hFFFFFFFF);
            end
            $display($time, " << Checking all registers are FF from A >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(1, index, 32'hFFFFFFFF);
            end
            $display($time, " << Checking all registers are FF from B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(2, index, 32'hFFFFFFFF);
            end
            $display($time, " << Checking all registers are FF from A/B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(3, index, 32'hFFFFFFFF);
            end
        end
    endtask

    task checkAll00;
        begin
            $display($time, " << Checking writting all 00 >>");
            for(index = 0; index < 32; index = index + 1) begin
                writeRegister(index, 32'h00000000);
            end
            $display($time, " << Checking all registers are 00 from A >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(1, index, 32'h00000000);
            end
            $display($time, " << Checking all registers are 00 from B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(2, index, 32'h00000000);
            end
            $display($time, " << Checking all registers are 00 from A/B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(3, index, 32'h00000000);
            end
        end
    endtask

    task checkBitPattern;
        input [31:0] pattern;
        begin
            $display($time, " << Checking writting bit pattern %h >>", pattern);
            for(index = 0; index < 32; index = index + 1) begin
                writeRegister(index, pattern);
            end
            $display($time, " << Checking all registers are bit pattern from A >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(1, index, pattern);
            end
            $display($time, " << Checking all registers are bit pattern from B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(2, index, pattern);
            end
            $display($time, " << Checking all registers are bit pattern from A/B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(3, index, pattern);
            end
        end
    endtask

    task checkRandomData;
        reg [1023:0] randomData;
        begin
            $display($time, " << Checking writting random data >>");
            for(index = 0; index < 32; index = index + 1) begin
                randomData[index * 32 +: 32] = $random;
            end
            for(index = 0; index < 32; index = index + 1) begin
                writeRegister(index, randomData[index * 32 +: 32]);
            end
            $display($time, " << Checking all registers are random data from A >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(1, index, randomData[index * 32 +: 32]);
            end
            $display($time, " << Checking all registers are random data from B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(2, index, randomData[index * 32 +: 32]);
            end
            $display($time, " << Checking all registers are random data from A/B >>");
            for(index = 0; index < 32; index = index + 1) begin
                checkRegister(3, index, randomData[index * 32 +: 32]);
            end
        end
    endtask
endmodule
