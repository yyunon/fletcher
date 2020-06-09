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

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;

entity SequenceStream is
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
    in_data                     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Input size stream.
    in_length_valid             : in  std_logic;
    in_length_ready             : out std_logic;
    in_length_data              : in  std_logic_vector(LENGTH_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(1, LENGTH_WIDTH));

    -- Output stream.
    out_valid                   : out std_logic;
    out_ready                   : in  std_logic;
    out_last                    : out std_logic;
    out_data                    : out std_logic_vector(DATA_WIDTH-1 downto 0)

  );
end SequenceStream;

architecture Behavioral of SequenceStream is

  -- Holding register for data, used when the output stream is blocked and the
  -- input stream is valid. This is needed to break the "ready" signal
  -- combinatorial path.
  signal saved_data             : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saved_length           : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saved_valid            : std_logic;
  
  
  -- Internal counter
  signal remaining              : signed(LENGTH_WIDTH downto 0);
  
  -- Length buffer ourpur stream.
  signal b_valid                : std_logic;
  signal b_ready                : std_logic;
  signal b_data                 : std_logic_vector(LENGTH_WIDTH-1 downto 0);

  -- Internal "copies" of the in_ready and out_valid control output signals.
  signal in_ready_s             : std_logic;
  signal out_valid_s            : std_logic;
  signal out_last_s             : std_logic;
  
  -- 

begin

length_buffer: StreamBuffer
    generic map (
      MIN_DEPTH                 => MIN_BUFFER_DEPTH,
      DATA_WIDTH                => LENGTH_WIDTH
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_length_valid,
      in_ready                  => in_length_ready,
      in_data                   => in_length_data,
      out_valid                 => b_valid,
      out_ready                 => b_ready,
      out_data                  => b_data
    );
    
reg_proc: process (clk) is
    variable diff : signed(LENGTH_WIDTH downto 0);
    variable last : std_logic;
  begin
    if rising_edge(clk) then
      -- We're ready for new data on the input unless otherwise specified.
      in_ready_s <= '1';
      
      b_ready <= '0';
      
      
      if remaining <= 0 then 
        b_ready <= '1';
      end if;
      
      if b_ready = '1' and b_valid = '1' then
        remaining <= remaining + signed(b_data);
        b_ready <= '0';
      end if;
      

      if saved_valid = '0' then

        -- Output faster than input or normal operation.
        if in_valid = '0' or in_ready_s = '0' then

          -- Input stalled, so if the output needs new data, we cannot provide
          -- any.
          if out_ready = '1' then
            out_valid_s <= '0';
            out_last_s  <= '0';
          end if;

        else -- in_valid = '1' and in_ready_s = '1'
          
          diff := signed(remaining) - signed(in_count);
          
          if diff = 0 then
            last := '1';
          else
            last := '0';
          end if;
          
          remaining <= diff;

          -- We need to take in a new data item from our input.
          if out_ready = '1' or out_valid_s = '0' then

            -- The output (register) is ready too, so we can push the new
            -- data item directly into the output.
            out_data <= in_data;
            out_valid_s <= '1';
            out_last_s <= last;

          else -- out_ready = '0' and out_valid_s = '1'

            -- The output is stalled, so we can't save the new data item in the
            -- output register. We put it in saved_data instead.
            saved_data <= in_data;
            saved_valid <= '1';

            -- We need to stall the input from the next cycle onwards, because
            -- we have no place to store new items until the output unblocks.
            in_ready_s <= '0';

          end if;

        end if;

      else -- saved_valid = '1'

        -- Handle and recover from input-faster-than-output condition.
        if out_ready = '0' then

          -- While the output is not ready yet, we need to keep blocking the
          -- input.
          in_ready_s <= '0';

        else -- out_ready = '1'

          -- The contents of the saved_data register are valid; we had to save
          -- an item there because the output stream stalled. So we need to
          -- output that item next, instead of the input data.
          out_data <= saved_data;
          out_valid_s <= '1';
          out_last_s <= last;


          -- Now that saved_data has moved to the output, it is no longer
          -- valid there.
          saved_valid <= '0';

        end if;

      end if;
      -- Reset overrides everything.
      if reset = '1' then
        in_ready_s  <= '0';
        --saved_data  <= (others => '0');
        saved_valid <= '0';
        --out_data    <= (others => '0');
        out_valid_s <= '0';
        
        b_ready <= '0';
        
        remaining <= to_signed(0, LENGTH_WIDTH+1);
      end if;
    end if;
  end process;

  -- Forward the internal "copies" of the control output signals.
  in_ready <= in_ready_s;
  out_valid <= out_valid_s;
  out_last <= out_last_s;
    
    

end Behavioral;
