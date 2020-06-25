----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/13/2020 10:50:34 AM
-- Design Name: 
-- Module Name: BatchIn_Map - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;
use work.ParallelPatterns_pkg.all;


entity MapStage is
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
   
end MapStage;

architecture Behavioral of MapStage is

  -- Stream to kernel
  signal krnl_out_valid          : std_logic;
  signal krnl_out_ready          : std_logic;
  signal krnl_out_dvalid         : std_logic;
  signal krnl_out_count          : std_logic_vector(0 downto 0);
  signal krnl_out_data           : std_logic_vector(63 downto 0);
  

  -- Stream from kernel
  signal krnl_in_valid           : std_logic;
  signal krnl_in_ready           : std_logic;
  signal krnl_in_dvalid          : std_logic;
  signal krnl_in_count           : std_logic_vector(1 downto 0);
  signal krnl_in_data            : std_logic_vector(63 downto 0);


begin

 map_cntrl : MapStream
    generic map (
      IN_DIMENSIONALITY    => 1,
      IN_COUNT_WIDTH       => 2,
      LENGTH_WIDTH         => INDEX_WIDTH,
      LENGTH_BUFFER_DEPTH  => 8
    )
    port map (
    clk                          => kcd_clk,
    reset                        => kcd_reset,
      
      -- Input stream.
    in_valid                     => map_in_valid,
    in_ready                     => map_in_ready,
    in_dvalid                    => map_in_dvalid,
    in_count                     => "01",
    in_last(0)                   => map_in_last,
                                 
    -- Stream to kernel 
    krnl_out_valid               => krnl_out_valid,
    krnl_out_ready               => krnl_out_ready,
    krnl_out_dvalid              => krnl_out_dvalid,
 
    -- Stream from kernel  
    krnl_in_valid                => krnl_in_valid,
    krnl_in_ready                => krnl_in_ready,
    krnl_in_dvalid               => krnl_in_dvalid,
    krnl_in_count                => krnl_in_count,
 
    -- Output stream             
    out_valid                    => map_out_valid,
    out_ready                    => map_out_ready,
    out_dvalid                   => map_out_dvalid,
    out_last(0)                  => map_out_last
    );
    
    krnl_in_count <= "01";
        
    --Test kernel
    dly: StreamSliceArray
    generic map (
      DATA_WIDTH                 => 65,
      DEPTH                      => 20
    )
    port map (
      clk                       => kcd_clk,
      reset                     => kcd_reset,

      in_valid                  => krnl_out_valid,
      in_ready                  => krnl_out_ready,
      in_data(63 downto 0)      => map_in,
      in_data(64)               => krnl_out_dvalid,

      out_valid                 => krnl_in_valid,
      out_ready                 => krnl_in_ready,
      out_data(63 downto 0)     => map_out,
      out_data(64)              => krnl_in_dvalid

    );

end Behavioral;
