library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;


entity FilterStream is
  generic (

    -- Width of the stream data vector.
    DATA_WIDTH                  : natural;
    
    -- Width of the stream data vector.
    LANE_COUNT                  : natural;
    
    -- Width of the stream data vector.
    DIMENSIONALITY              : natural := 1;
    
    -- Minimum depth of the transaction buffer
    MIN_BUFFER_DEPTH            : natural := 1

  );
  port (

    -- Rising-edge sensitive clock.
    clk                         : in  std_logic;

    -- Active-high synchronous reset.
    reset                       : in  std_logic;

    -- Input stream.
    in_valid                    : in  std_logic;
    in_ready                    : out std_logic;
    in_data                     : in  std_logic_vector(DATA_WIDTH*LANE_COUNT-1 downto 0);
    in_last                     : in  std_logic_vector(DIMENSIONALITY-1 downto 0);

    -- Output stream.
    out_valid                   : out std_logic;
    out_ready                   : in  std_logic;
    out_data                    : out std_logic_vector(DATA_WIDTH*LANE_COUNT-1 downto 0);
    out_strb                    : out std_logic_vector(LANE_COUNT-1 downto 0);
    out_last                    : out std_logic_vector(LANE_COUNT*DIMENSIONALITY-1 downto 0)
  );
end FilterStream;

architecture Behavioral of FIlterStream is


begin
    

  
end Behavioral;
