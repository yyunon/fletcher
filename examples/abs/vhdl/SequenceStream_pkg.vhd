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

package SequenceStream_pkg is

  component SequenceStream is
    generic (


    -- Minimum depth of the length buffer
    MIN_BUFFER_DEPTH            : natural := 1;
    
    -- Width of the lenght input and internal counter.
    LENGTH_WIDTH                : natural := 8;
    
    -- Width of the stream data vector.
    DATA_WIDTH                  : natural;
    
    -- No transaction is accepted on the data stream when there's no handshaked length in the buffer.
    -- In case of a non-blocking setup, incoming trasactions are accepted and the counter is started in advance.
    -- In this case, the source has to make sure that there are less incoming values than the next arriving length value.
    BLOCKING                    : boolean := false
  );
  port (

    -- Rising-edge sensitive clock.
    clk                         : in  std_logic;

    -- Active-high synchronous reset.
    reset                       : in  std_logic;

    -- Input data stream.
    in_valid                    : in  std_logic;
    in_ready                    : out std_logic;
    in_count                    : in  std_logic_vector(LENGTH_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, LENGTH_WIDTH));
    in_dvalid                   : in  std_logic := '1';
    
    -- Input size stream.
    in_length_valid             : in  std_logic;
    in_length_ready             : out std_logic;
    in_length_data              : in  std_logic_vector(LENGTH_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, LENGTH_WIDTH));

    -- Output stream.
    out_valid                   : out std_logic;
    out_ready                   : in  std_logic;
    out_last                    : out std_logic
  );
  end component;

end SequenceStream_pkg;
