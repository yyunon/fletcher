library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;


entity ReduceStream is
  generic (

    -- Width of the stream data vector.
    DATA_WIDTH                  : natural;
    
    -- Width of the stream data vector.
    IN_DIMENSIONALITY           : natural := 1;
    
    -- Bitwidth of the sequence counter
    LENGTH_WIDTH                : natural := 8
    

  );
  port (

    -- Rising-edge sensitive clock.
    clk                         : in  std_logic;

    -- Active-high synchronous reset.
    reset                       : in  std_logic;

    -- Input stream.
    in_valid                    : in  std_logic;
    in_ready                    : out std_logic;
    in_count                    : in  std_logic_vector(LENGTH_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, LENGTH_WIDTH));
    in_last                     : in  std_logic_vector(IN_DIMENSIONALITY-1 downto 0);
    
    -- Accumulator output stream.
    acc_out_valid               : out  std_logic;
    acc_out_ready               : in std_logic;
    acc_out_data                : out  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Accumulator input stream.
    acc_in_valid               : in  std_logic;
    acc_in_ready               : out std_logic;
    acc_in_data                : in  std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Output stream.
    out_valid                   : out std_logic;
    out_ready                   : in  std_logic;
    out_data                    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    out_last                    : out std_logic_vector(IN_DIMENSIONALITY-2 downto 0)
  );
end ReduceStream;

architecture Behavioral of ReduceStream is

  signal count_valid                : std_logic;
  signal count_ready                : std_logic;
  signal count                      : std_logic_vector(LENGTH_WIDTH-1 downto 0);
  signal count_last                 : std_logic;


begin
    
element_counter: StreamElementCounter
    generic map (
      IN_COUNT_MAX              => 10,
      IN_COUNT_WIDTH            => 8,
      OUT_COUNT_MAX             => 10,
      OUT_COUNT_WIDTH           => 8
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_dvalid                 => '1',
      in_count                  => in_count,
      in_last                   => in_last(0),
      out_valid                 => count_valid,
      out_ready                 => count_ready,
      out_last                  => count_last,
      out_count                 => count
    );
    
    
 sequencer: SequenceStream
    generic map (
      MIN_BUFFER_DEPTH           => 10,
      LENGTH_WIDTH               => 8,
      BLOCKING                   => false
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => dly_out_valid,
      in_ready                  => dly_out_ready,
      in_dvalid                 => '1',
      in_count                  => "00000001",
      in_length_valid           => count_valid,
      in_length_ready           => count_ready,
      in_length_data            => count,
      out_valid                 => BatchOut_vectors_valid,
      out_ready                 => BatchOut_vectors_ready,
      out_last                  => BatchOut_vectors_last
    );
  
end Behavioral;
