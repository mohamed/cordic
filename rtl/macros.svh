`define DFF(clk,rst,d,q,rst_val) \
    always_ff @(posedge clk) begin \
        if (!rst) begin \
            q <= rst_val; \
        end else begin \
            q <= d; \
        end \
    end

`define DFFE(clk,rst,en,d,q,rst_val) \
    always_ff @(posedge clk) begin \
        if (!rst) begin \
            q <= rst_val; \
        end else begin \
            if (en) begin \
                q <= d; \
            end \
        end \
    end

`define real2fixed(r,Q_I,Q_F)   (1+Q_I+Q_F)'(longint'(r * (2.0**Q_F)))

`define fixed2real(f,Q_F)       ($itor(f) * (2.0**(-Q_F)))

`define SLICE(v,n)              v[(2*n-n/2)-1:n/2]

`define STATIC_ASSERT(c)     \
    initial begin \
      if (!(c)) begin \
        $error(`"STATIC_ASSERT: c`"); \
        $finish; \
      end \
    end

`define is_pow_of_2(v)      ((v & (v-1)) == 0)
