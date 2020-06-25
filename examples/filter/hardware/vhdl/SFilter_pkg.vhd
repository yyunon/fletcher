----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ákos Hadnagy
-- 
-- Create Date: 05/29/2020 03:41:48 PM
-- Design Name: 
-- Module Name: SequenceStream - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

package SFilter_pkg is

  component regex_match is
  generic (

    ----------------------------------------------------------------------------
    -- Configuration
    ----------------------------------------------------------------------------
    -- Number of bytes that can be handled per cycle.
    BPC                         : positive := 1;

    -- Whether or not the system is big endian. This determines in which order
    -- the incoming bytes are processed.
    BIG_ENDIAN                  : boolean := false;

    -- Pipeline configuration flags. Disabling stage registers reduces register
    -- usage but *may* come at the cost of performance.
    INPUT_REG_ENABLE            : boolean := false;
    S12_REG_ENABLE              : boolean := true;
    S23_REG_ENABLE              : boolean := true;
    S34_REG_ENABLE              : boolean := true;
    S45_REG_ENABLE              : boolean := true

  );
  port (

    ----------------------------------------------------------------------------
    -- Clock input
    ----------------------------------------------------------------------------
    -- `clk` is rising-edge sensitive.
    clk                         : in  std_logic;

    -- `reset` is an active-high synchronous reset, `aresetn` is an active-low
    -- asynchronous reset, and `clken` is an active-high global clock enable
    -- signal. The resets override the clock enable signal. If your system has
    -- no need for one or more of these signals, simply do not connect them.
    reset                       : in  std_logic := '0';
    aresetn                     : in  std_logic := '1';
    clken                       : in  std_logic := '1';

    ----------------------------------------------------------------------------
    -- Incoming UTF-8 bytestream
    ----------------------------------------------------------------------------
    -- AXI4-style handshake signals. If `out_ready` is not used, `in_ready` can
    -- be ignored because it will always be high.
    in_valid                    : in  std_logic := '1';
    in_ready                    : out std_logic;

    -- Incoming byte(s). Each byte has its own validity flag (`in_mask`). This
    -- is independent of the "last" flags, allowing empty strings to be
    -- encoded. Bytes are interpreted LSB-first by default, or MSB-first if the
    -- `BIG_ENDIAN` generic is set.
    in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
    in_data                     : in  std_logic_vector(BPC*8-1 downto 0);

    -- "Last-byte-in-string" marker signal for systems which support at most
    -- one *string* per cycle.
    in_last                     : in  std_logic := '0';

    -- ^
    -- | Use exactly one of these!
    -- v

    -- "Last-byte-in-string" marker signal for systems which support multiple
    -- *strings* per cycle. Each bit corresponds to a byte in `in_mask` and
    -- `in_data`.
    in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');

    ----------------------------------------------------------------------------
    -- Outgoing match stream
    ----------------------------------------------------------------------------
    -- AXI4-style handshake signals. `out_ready` can be left unconnected if the
    -- stream sink can never block (for instance a simple match counter), in
    -- which case the input stream can never block either.
    out_valid                   : out std_logic;
    out_ready                   : in  std_logic := '1';

    -- Outgoing match stream for one-string-per-cycle systems. match indicates
    -- which of the following regexs matched:
    --  - 0: /covfefe/
    -- error indicates that a UTF-8 decoding error occured. Only the following
    -- decode errors are detected:
    --  - multi-byte sequence interrupted by last flag or a new sequence
    --    (interrupted sequence is ignored)
    --  - unexpected continuation byte (byte is ignored)
    --  - illegal bytes 0xC0..0xC1, 0xF6..0xF8 (parsed as if they were legal
    --    2-byte/4-byte start markers; for the latter three this means that
    --    oh3 will be "00000", which means the character won't match anything)
    --  - illegal bytes 0xF8..0xFF (ignored)
    -- Thus, the following decode errors pass silently:
    --  - code points 0x10FFFF to 0x13FFFF (these are out of range, at least
    --    at the time of writing)
    --  - overlong sequences which are not apparent from the first byte
    out_match                   : out std_logic_vector(0 downto 0);
    out_error                   : out std_logic;

    -- Outgoing match stream for multiple-string-per-cycle systems.
    out_xmask                   : out std_logic_vector(BPC-1 downto 0);
    out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
    out_xerror                  : out std_logic_vector(BPC-1 downto 0)

  );
 end component;

 component MapStage is
 generic (
    INDEX_WIDTH          : natural
  );
  port (
    kcd_clk              : in  std_logic;
    kcd_reset            : in  std_logic;
    map_in_valid         : in  std_logic;
    map_in_ready         : out std_logic;
    map_in_dvalid        : in  std_logic;
    map_in_last          : in  std_logic;
    map_in               : in  std_logic_vector(63 downto 0);
    
    map_out_valid        : out std_logic;
    map_out_ready        : in  std_logic;
    map_out_dvalid       : out std_logic;
    map_out_last         : out std_logic;
    map_out              : out std_logic_vector(63 downto 0)
    );
   
 end component;
 
 component SumOp is
  generic (

    -- Width of the stream data vector.
    DATA_WIDTH                  : natural
   

  );
  port (

    -- Rising-edge sensitive clock.
    clk                          : in  std_logic;

    -- Active-high synchronous reset.
    reset                        : in  std_logic;

    --OP1 Input stream.
    op1_valid                    : in  std_logic;
    op1_dvalid                   : in  std_logic := '1';
    op1_ready                    : out std_logic;
    op1_data                     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    --OP2 Input stream.
    op2_valid                    : in  std_logic;
    op2_dvalid                   : in  std_logic := '1';
    op2_ready                    : out std_logic;
    op2_data                     : in  std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Output stream.
    out_valid                    : out std_logic;
    out_ready                    : in  std_logic;
    out_data                     : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_dvalid                   : out std_logic
  );
end component;
  
  component ReduceStage is
  generic (
    INDEX_WIDTH : integer := 32;
    TAG_WIDTH   : integer := 1
  );
  port (
    clk                          : in  std_logic;
    reset                        : in  std_logic;
    
    in_valid                     : in  std_logic;
    in_dvalid                    : in  std_logic  := '1';
    in_ready                     : out std_logic;
    in_last                      : in  std_logic;
    in_data                      : in  std_logic_vector(63 downto 0);
    
    out_valid                    : out std_logic;
    out_ready                    : in  std_logic;
    out_data                     : out std_logic_vector(63 downto 0)
    
  );
end component;

end SFilter_pkg;
