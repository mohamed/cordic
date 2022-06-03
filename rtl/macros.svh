
`define DFF(clk,rst,d,q,rst_val) \
    always_ff @(posedge clk, negedge rst) begin \
        if (!rst) begin \
            q <= rst_val; \
        end else begin \
            q <= d; \
        end \
    end

`define DFFE(clk,rst,en,d,q,rst_val) \
    always_ff @(posedge clk, negedge rst) begin \
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

// extract a Qi.f fixed point from l length vector
`define shrink_fixed(v,l,i,f)   v[(l/2+(i+1))-1:(l/2)-f]

`define expand_fixed(x,xi,xf,yi,yf) \
  {x[(xi+xf+1)-1], (yi-xi)'(0), x[(xi+xf)-1:xf], x[xf-1:0], (yf-xf)'(0)}

`define STATIC_ASSERT(c)     \
    initial begin \
      if (!(c)) begin \
        $error(`"STATIC_ASSERT: c`"); \
        $finish; \
      end \
    end

`define is_pow_of_2(v)      (v > 1 && ((v & (v-1)) == 0))
