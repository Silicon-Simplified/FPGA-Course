// Episode 32 - measures the VGA core from its OUTPUT pins only: line/frame length, sync widths, blanking, the logo path; and dumps two frames as PPM images.
`timescale 1ns/1ps
module tb_vga;
    reg clk = 0; always #20 clk = ~clk;                // 25 MHz
    reg rst = 1;
    wire [3:0] r, g, b; wire hs_n, vs_n, bounce;
    vga_core dut (.clk(clk), .rst(rst), .r(r), .g(g), .b(b), .hs_n(hs_n), .vs_n(vs_n), .bounce(bounce));

    reg act_d = 0, hs_d = 1, vs_d = 1;
    integer clk_n = 0, last_hs_fall = -1, last_vs_fall = -1, last_hs_rise = 0, last_vs_rise = 0;
    integer line_len = 0, hs_width = 0, frame_len = 0, vs_width = 0;
    integer line_bad = 0, frame_bad = 0, black_bad = 0, act_count = 0, act_last = 0, act_bad = 0;
    integer frames = 0, bounces = 0, path_bad = 0, nlines = 0;
    integer fa = 0, fb = 0, fpath;
    localparam FRAMES = 600, DUMPA = 2, DUMPB = 300;
    initial begin
        fpath = $fopen("logo_path.csv", "w"); $fdisplay(fpath, "frame,x,y,color_sel");
        fa = $fopen("frame_a.ppm", "wb"); fb = $fopen("frame_b.ppm", "wb");
        $fwrite(fa, "P6\n640 480\n255\n"); $fwrite(fb, "P6\n640 480\n255\n");
        repeat (4) @(posedge clk); rst = 0;
    end
    always @(posedge clk) if (!rst) begin
        clk_n <= clk_n + 1;
        act_d <= dut.active; hs_d <= hs_n; vs_d <= vs_n;
        // sync-pulse measurements on the output pins
        if (hs_d && !hs_n) begin
            if (last_hs_fall >= 0) begin line_len = clk_n - last_hs_fall; if (line_len != 800) line_bad = line_bad + 1; end
            last_hs_fall = clk_n;
        end
        if (!hs_d && hs_n) begin hs_width = clk_n - last_hs_fall; end
        if (vs_d && !vs_n) begin
            if (last_vs_fall >= 0) begin frame_len = clk_n - last_vs_fall; if (frame_len != 420000) frame_bad = frame_bad + 1; frames = frames + 1; end
            last_vs_fall = clk_n;
        end
        if (!vs_d && vs_n) vs_width = clk_n - last_vs_fall;
        // blanking must be black; count visible pixels per frame
        if (frames >= 1 && !act_d && {r, g, b} != 12'h000) black_bad = black_bad + 1;
        if (act_d) act_count = act_count + 1;
        if (vs_d && !vs_n) begin if (frames > 1 && act_count != 307200) act_bad = act_bad + 1; act_last = act_count; act_count = 0; end
        // dump frames
        if (act_d && frames == DUMPA) $fwrite(fa, "%c%c%c", {r, r}, {g, g}, {b, b});
        if (act_d && frames == DUMPB) $fwrite(fb, "%c%c%c", {r, r}, {g, g}, {b, b});
        if (bounce) bounces = bounces + 1;
        if (dut.tick) begin
            $fdisplay(fpath, "%0d,%0d,%0d,%0d", frames, dut.lx, dut.ly, dut.sel);
            if (dut.lx + 64 > 640 || dut.ly + 48 > 480) path_bad = path_bad + 1;
        end
        if (frames == FRAMES) begin
            $display("VGA line = %0d clocks (bad lines: %0d), hsync low = %0d clocks", line_len, line_bad, hs_width);
            $display("VGA frame = %0d clocks = %0d lines (bad frames: %0d), vsync low = %0d clocks = %0d lines", frame_len, frame_len / 800, frame_bad, vs_width, vs_width / 800);
            $display("VGA visible pixels per frame = %0d (bad frames: %0d)", act_last, act_bad);
            $display("VGA colour outside the picture: %0d clocks non-black", black_bad);
            $display("VGA logo: %0d frames, %0d bounces, %0d positions out of bounds", frames, bounces, path_bad);
            $display("VGA pixel clock 25 MHz -> line %0d Hz, frame %0.2f Hz", 25000000 / 800, 25000000.0 / 420000.0);
            $fclose(fa); $fclose(fb); $fclose(fpath);
            $finish;
        end
    end
endmodule
