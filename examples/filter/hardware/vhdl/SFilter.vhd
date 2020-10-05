
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.SFilter_pkg.all;
use work.Stream_pkg.all;
use work.ParallelPatterns_pkg.all;



entity SFilter is
  generic (
    INDEX_WIDTH : integer := 32;
    TAG_WIDTH   : integer := 1
  );
  port (
    kcd_clk                          : in  std_logic;
    kcd_reset                        : in  std_logic;
    ExampleBatch_string_valid        : in  std_logic;
    ExampleBatch_string_ready        : out std_logic;
    ExampleBatch_string_dvalid       : in  std_logic;
    ExampleBatch_string_last         : in  std_logic;
    ExampleBatch_string_length       : in  std_logic_vector(31 downto 0);
    ExampleBatch_string_count        : in  std_logic_vector(0 downto 0);
    ExampleBatch_string_chars_valid  : in  std_logic;
    ExampleBatch_string_chars_ready  : out std_logic;
    ExampleBatch_string_chars_dvalid : in  std_logic;
    ExampleBatch_string_chars_last   : in  std_logic;
    ExampleBatch_string_chars        : in  std_logic_vector(159 downto 0);
    ExampleBatch_string_chars_count  : in  std_logic_vector(4 downto 0);
    ExampleBatch_number_valid        : in  std_logic;
    ExampleBatch_number_ready        : out std_logic;
    ExampleBatch_number_dvalid       : in  std_logic;
    ExampleBatch_number_last         : in  std_logic;
    ExampleBatch_number              : in  std_logic_vector(63 downto 0);
    ExampleBatch_string_unl_valid    : in  std_logic;
    ExampleBatch_string_unl_ready    : out std_logic;
    ExampleBatch_string_unl_tag      : in  std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_number_unl_valid    : in  std_logic;
    ExampleBatch_number_unl_ready    : out std_logic;
    ExampleBatch_number_unl_tag      : in  std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_string_cmd_valid    : out std_logic;
    ExampleBatch_string_cmd_ready    : in  std_logic;
    ExampleBatch_string_cmd_firstIdx : out std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_string_cmd_lastIdx  : out std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_string_cmd_tag      : out std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_valid    : out std_logic;
    ExampleBatch_number_cmd_ready    : in  std_logic;
    ExampleBatch_number_cmd_firstIdx : out std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_lastIdx  : out std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_tag      : out std_logic_vector(TAG_WIDTH-1 downto 0);
    start                            : in  std_logic;
    stop                             : in  std_logic;
    reset                            : in  std_logic;
    idle                             : out std_logic;
    busy                             : out std_logic;
    done                             : out std_logic;
    result                           : out std_logic_vector(63 downto 0);
    ExampleBatch_firstidx            : in  std_logic_vector(31 downto 0);
    ExampleBatch_lastidx             : in  std_logic_vector(31 downto 0)
  );
end entity;

architecture Implementation of SFilter is


  -- Enumeration type for our state machine.
  type state_t is (STATE_IDLE, 
                   STATE_COMMAND, 
                   STATE_CALCULATING, 
                   STATE_UNLOCK, 
                   STATE_DONE);
                   
  signal state_slv : std_logic_vector(1 downto 0);


  
  -- Current state register and next state signal.
  signal state, state_next : state_t;


  signal char_valid_mask        : std_logic_vector(19 downto 0);
  signal matcher_out_valid      : std_logic;
  signal matcher_out_ready      : std_logic;  
  signal matcher_out_match      : std_logic;
  signal match_in_ready         : std_logic;
  
  signal matcher_out_s_valid    : std_logic;
  signal matcher_out_s_ready    : std_logic;  
  signal matcher_out_s_match    : std_logic;
  
  signal matcher_in_s_valid     : std_logic;
  signal matcher_in_s_ready     : std_logic;
  signal matcher_in_s_data      : std_logic_vector(159 downto 0);
  signal matcher_in_s_mask      : std_logic_vector(19 downto 0);    
  signal matcher_in_s_last      : std_logic;
  
  signal filter_out_valid       : std_logic;
  signal filter_out_ready       : std_logic;
  signal filter_out_last        : std_logic;
  signal filter_out_strb        : std_logic;
  signal filter_out_data        : std_logic_vector(63 downto 0);
  
  
--  signal map_out_valid          : std_logic;
--  signal map_out_ready          : std_logic;
--  signal map_out_data           : std_logic_vector(63 downto 0);
--  signal map_out_dvalid         : std_logic;
--  signal map_out_last           : std_logic;
  
  
--  signal drop_out_ready         : std_logic;
--  signal drop_out_valid         : std_logic;
  
  -- Sum output stream.
  signal sum_out_valid          : std_logic;
  signal sum_out_ready          : std_logic;
  signal sum_out_data           : std_logic_vector(63 downto 0);
  
--  --output internal copies
--  signal ExampleBatch_string_ready_s            : std_logic;
--  signal ExampleBatch_string_chars_ready_s      : std_logic;
--  signal ExampleBatch_number_ready_s            : std_logic;
--  signal ExampleBatch_string_unl_ready_s        : std_logic;
--  signal ExampleBatch_number_unl_ready_s        : std_logic;
--  signal ExampleBatch_string_cmd_valid_s        : std_logic;
--  signal ExampleBatch_number_cmd_valid_s        : std_logic;
  
--  signal idle_s                                 : std_logic;
--  signal busy_s                                 : std_logic;
--  signal done_s                                 : std_logic;
--  signal result_s                               : std_logic_vector(63 downto 0);

--    COMPONENT ila_0
    
--    PORT (
--        clk : IN STD_LOGIC;
--        probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe8 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
--        probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe13 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
--        probe14 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe15 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe16 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe17 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe18 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe19 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe20 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe21 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe22 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe23 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe24 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe25 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe26 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe27 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
--        probe28 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe29 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe30 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe31 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe32 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe33 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe34 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe35 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--        probe36 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
--        probe37 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
--        probe38 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        probe39 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
--    );
--    END COMPONENT;
                            
  
  
begin

--  ExampleBatch_string_ready           <= ExampleBatch_string_ready_s;      
--  ExampleBatch_string_chars_ready     <= ExampleBatch_string_chars_ready_s;
--  ExampleBatch_number_ready           <= ExampleBatch_number_ready_s;      
--  ExampleBatch_string_unl_ready       <= ExampleBatch_string_unl_ready_s;  
--  ExampleBatch_number_unl_ready       <= ExampleBatch_number_unl_ready_s; 
--  ExampleBatch_string_cmd_valid       <= ExampleBatch_string_cmd_valid_s;  
--  ExampleBatch_number_cmd_valid       <= ExampleBatch_number_cmd_valid_s;  
--  idle                                <= idle_s;                           
--  busy                                <= busy_s;                           
--  done                                <= done_s;                           
--  result                              <= result_s;      

   --Ont-hot encoded char mask for matcher.
    with ExampleBatch_string_chars_count(4 downto 0) select char_valid_mask <=
     "00000000000000000001" when "00001",
     "00000000000000000011" when "00010", 
     "00000000000000000111" when "00011", 
     "00000000000000001111" when "00100",
     "00000000000000011111" when "00101", 
     "00000000000000111111" when "00110",
     "00000000000001111111" when "00111",
     "00000000000011111111" when "01000",
     "00000000000111111111" when "01001",
     "00000000001111111111" when "01010", 
     "00000000011111111111" when "01011", 
     "00000000111111111111" when "01100",
     "00000001111111111111" when "01101", 
     "00000011111111111111" when "01110",
     "00000111111111111111" when "01111",
     "00001111111111111111" when "10000",
     "00011111111111111111" when "10001",
     "00111111111111111111" when "10010", 
     "01111111111111111111" when "10011", 
     "11111111111111111111" when "10100",
     "00000000000000000000" when others;
     
  regex_in_slice: StreamSlice
    generic map (
      DATA_WIDTH                 => 181
    )
    port map (
      clk                       => kcd_clk,
      reset                     => kcd_reset or reset,

      in_valid                  => ExampleBatch_string_chars_valid,
      in_ready                  => match_in_ready,
      in_data(0)                => ExampleBatch_string_chars_last,
      in_data(160 downto 1)     => ExampleBatch_string_chars,
      in_data(180 downto 161)   => char_valid_mask,


      out_valid                 => matcher_in_s_valid,
      out_ready                 => matcher_in_s_ready,
      out_data(0)               => matcher_in_s_last,
      out_data(160 downto 1)    => matcher_in_s_data,
      out_data(180 downto 161)  => matcher_in_s_mask
      );

  matcher: regex_match
    generic map (
      BPC                       => 20
    )
    port map (
      clk                       => kcd_clk,
      reset                     => kcd_reset or reset,
      in_valid                  => matcher_in_s_valid,
      in_ready                  => matcher_in_s_ready,
      in_last                   => matcher_in_s_last,
      in_data                   => matcher_in_s_data,
      in_mask                   => matcher_in_s_mask,
      out_valid                 => matcher_out_valid,
      out_ready                 => matcher_out_ready,
      out_match(0)              => matcher_out_match
    );
    
    ExampleBatch_string_ready <= match_in_ready;
    ExampleBatch_string_chars_ready <= match_in_ready;
        
    regex_out_slice: StreamSlice
    generic map (
      DATA_WIDTH                 => 1
    )
    port map (
      clk                       => kcd_clk,
      reset                     => kcd_reset or reset,

      in_valid                  => matcher_out_valid,
      in_ready                  => matcher_out_ready,
      in_data(0)                => matcher_out_match,


      out_valid                 => matcher_out_s_valid,
      out_ready                 => matcher_out_s_ready,
      out_data(0)               => matcher_out_s_match
      );
    
    
    filter_stage: FilterStream
      generic map(
        LANE_COUNT                  => 1,
        INDEX_WIDTH                 => INDEX_WIDTH-1,
        DIMENSIONALITY              => 1,
        MIN_BUFFER_DEPTH            => 64
      )
      port map(
        
        clk                         => kcd_clk,
        reset                       => kcd_reset or reset,
        in_valid                    => ExampleBatch_number_valid,
        in_ready                    => ExampleBatch_number_ready,
        in_last(0)                  => ExampleBatch_number_last,
                                    
        pred_in_valid               => matcher_out_s_valid,
        pred_in_ready               => matcher_out_s_ready,
        pred_in_data(0)             => matcher_out_s_match,
                                    
        out_valid                   => filter_out_valid,
        out_ready                   => filter_out_ready,
        out_strb(0)                 => filter_out_strb,
        out_last(0)                 => filter_out_last
      );
      
    --drop_empty: DropEmpty
    --port map (
    --  clk                       => kcd_clk,
    --  reset                     => kcd_reset,

    --  in_valid                  => filter_out_valid,
    --  in_ready                  => filter_out_ready,
    --  in_dvalid                 => filter_out_strb,


    --  out_valid                 => drop_out_valid,
    --  out_ready                 => drop_out_ready
    --  );
      
    --filter_out_ready <= '1';
--    map_stage: MapStage
--      generic map (
--        INDEX_WIDTH => INDEX_WIDTH-1
--      )
--      port map(
--        kcd_clk              => kcd_clk,
--        kcd_reset            => kcd_reset or reset,
--        map_in_valid         => filter_out_valid,
--        map_in_ready         => filter_out_ready,
--        map_in_dvalid        => filter_out_strb,
--        map_in_last          => filter_out_last,
--        map_in               => ExampleBatch_number(63 downto 0),
        
--        map_out_valid        => map_out_valid,
--        map_out_ready        => map_out_ready,
--        map_out_dvalid       => map_out_dvalid,
--        map_out_last         => map_out_last,
--        map_out              => map_out_data
--      );
    
    
--    reduce_stage: ReduceStage
--    generic map (
--        INDEX_WIDTH => INDEX_WIDTH-1
--      )
--    port map (
--      clk                       => kcd_clk,
--      reset                     => kcd_reset or reset,
--      in_valid                  => map_out_valid,
--      in_ready                  => map_out_ready,
--      in_dvalid                 => map_out_dvalid,
--      in_last                   => map_out_last,
--      in_data                   => map_out_data,
--      out_valid                 => sum_out_valid,
--      out_ready                 => sum_out_ready,
--      out_data                  => sum_out_data
--    );
    
    
    reduce_stage: ReduceStage
    generic map (
        INDEX_WIDTH => INDEX_WIDTH-1
      )
    port map (
      clk                       => kcd_clk,
      reset                     => kcd_reset or reset,
      in_valid                  => filter_out_valid,
      in_ready                  => filter_out_ready,
      in_dvalid                 => filter_out_strb,
      in_last                   => filter_out_last,
      in_data                   => ExampleBatch_number,
      out_valid                 => sum_out_valid,
      out_ready                 => sum_out_ready,
      out_data                  => sum_out_data
    );
    
--    dbg_ila : ila_0
--    PORT MAP (
--        clk => kcd_clk,
--        probe0(0) => ExampleBatch_string_valid, 
--        probe1(0) => ExampleBatch_string_ready_s, 
--        probe2(0) => ExampleBatch_string_dvalid, 
--        probe3(0) => ExampleBatch_string_last, 
--        probe4(0) => ExampleBatch_string_chars_valid, 
--        probe5(0) => ExampleBatch_string_chars_ready_s, 
--        probe6(0) => ExampleBatch_string_chars_dvalid, 
--        probe7(0) => ExampleBatch_string_chars_last,
--        probe8 => ExampleBatch_string_chars(7 downto 0),
--        probe9(0) => ExampleBatch_number_valid, 
--        probe10(0) => ExampleBatch_number_ready_s, 
--        probe11(0) => ExampleBatch_number_dvalid, 
--        probe12(0) => ExampleBatch_number_last, 
--        probe13 => ExampleBatch_number(7 downto 0), 
--        probe14(0) => ExampleBatch_string_unl_valid, 
--        probe15(0) => ExampleBatch_string_unl_ready_s, 
--        probe16(0) => ExampleBatch_number_unl_valid, 
--        probe17(0) => ExampleBatch_number_unl_ready_s, 
--        probe18(0) => ExampleBatch_string_cmd_valid_s, 
--        probe19(0) => ExampleBatch_string_cmd_ready, 
--        probe20(0) => ExampleBatch_number_cmd_valid_s, 
--        probe21(0) => ExampleBatch_number_cmd_ready, 
--        probe22(0) => start, 
--        probe23(0) => stop, 
--        probe24(0) => reset, 
--        probe25(0) => idle_s, 
--        probe26(0) => busy_s, 
--        probe27 => result_s(7 downto 0), 
--        probe28(0) => matcher_out_valid, 
--        probe29(0) => matcher_out_ready, 
--        probe30(0) => matcher_out_match, 
--        probe31(0) => filter_out_valid, 
--        probe32(0) => filter_out_ready, 
--        probe33(0) => filter_out_strb, 
--        probe34(0) => sum_out_valid, 
--        probe35(0) => sum_out_ready, 
--        probe36 => sum_out_data(7 downto 0), 
--        probe37 => ExampleBatch_firstidx(7 downto 0), 
--        probe38 => ExampleBatch_lastidx(7 downto 0),
--        probe39(0) => done_s
--    );

  with state select state_slv <= "00" when STATE_COMMAND,
                 "01" when STATE_CALCULATING,
                 "10" when STATE_UNLOCK,
                 "11" when others;
    

  combinatorial_proc : process (
        ExampleBatch_firstIdx, 
        ExampleBatch_lastIdx, 
        ExampleBatch_number_cmd_ready,
        ExampleBatch_number_unl_valid,
        ExampleBatch_string_cmd_ready,
        ExampleBatch_string_unl_valid,
        sum_out_valid,
        state,
        start,
        reset,
        kcd_reset) is 
  begin

    ExampleBatch_number_cmd_valid    <= '0';
    ExampleBatch_number_cmd_firstIdx <= (others => '0');
    ExampleBatch_number_cmd_lastIdx  <= (others => '0');
    ExampleBatch_number_cmd_tag      <= (others => '0');
    
    ExampleBatch_string_cmd_valid    <= '0';
    ExampleBatch_string_cmd_firstIdx <= (others => '0');
    ExampleBatch_string_cmd_lastIdx  <= (others => '0');
    ExampleBatch_string_cmd_tag      <= (others => '0');
    
    ExampleBatch_number_unl_ready <= '0'; -- Do not accept "unlocks".
    ExampleBatch_string_unl_ready <= '0'; -- Do not accept "unlocks".
    state_next <= state;                  -- Retain current state.
    
    sum_out_ready <='0';

    case state is
      when STATE_IDLE =>
        -- Idle: We just wait for the start bit to come up.
        done <= '0';
        busy <= '0';
        idle <= '1';
                
        -- Wait for the start signal (typically controlled by the host-side 
        -- software).
        if start = '1' then
          state_next <= STATE_COMMAND;
        end if;

      when STATE_COMMAND =>
        -- Command: we send a command to the generated interface.
        done <= '0';
        busy <= '1';  
        idle <= '0';
                
        -- The command is a stream, so we assert its valid bit and wait in this
        -- state until it is accepted by the generated interface. If the valid
        -- and ready bit are both asserted in the same cycle, the command is
        -- accepted.        
        -- We need to supply a command to the generated interface for each 
        -- Arrow field. In the case of this kernel, that means we just have to
        -- generate a single command. The command is sent on the command stream 
        -- to the generated interface.
        -- The command includes a range of rows from the recordbatch we want to
        -- work on. In this simple example, we just want this kernel to work on 
        -- all the rows in the RecordBatch. 
        -- The starting row and ending row (exclusive) that this kernel should 
        -- work on is supplied via MMIO and appears on the firstIdx and lastIdx 
        -- ports.
        -- We can use the tag field of the command stream to identify different 
        -- commands. We don't really use it for this example, so we just set it
        -- to zero.
        ExampleBatch_number_cmd_valid    <= '1';
        ExampleBatch_number_cmd_firstIdx <= ExampleBatch_firstIdx;
        ExampleBatch_number_cmd_lastIdx  <= ExampleBatch_lastIdx;
        ExampleBatch_number_cmd_tag      <= (others => '0');
        
        ExampleBatch_string_cmd_valid    <= '1';
        ExampleBatch_string_cmd_firstIdx <= ExampleBatch_firstIdx;
        ExampleBatch_string_cmd_lastIdx  <= ExampleBatch_lastIdx;
        ExampleBatch_string_cmd_tag      <= (others => '0');
        
        if ExampleBatch_number_cmd_ready = '1' and ExampleBatch_string_cmd_ready = '1' then
          state_next <= STATE_CALCULATING;
        end if;

      when STATE_CALCULATING =>
        -- Calculating: we stream in and accumulate the numbers one by one.
        done <= '0';
        busy <= '1';  
        idle <= '0';
        
        sum_out_ready <='1';
          
        -- All we have to do now is check if the last number was supplied.
        -- If that is the case, we can go to the "done" state.
        if sum_out_valid = '1' then
          state_next <= STATE_UNLOCK;
        end if;
        
      when STATE_UNLOCK =>
        -- Unlock: the generated interface delivered all items in the stream.
        -- The unlock stream is supplied to make sure all bus transfers of the
        -- corresponding command are completed.
        done <= '1';
        busy <= '0';
        idle <= '1';
        
        -- Ready to handshake the unlock stream:
        ExampleBatch_number_unl_ready <= '1';
        ExampleBatch_string_unl_ready <= '1';
        -- Handshake when it is valid and go to the done state.
        if ExampleBatch_number_unl_valid = '1' and ExampleBatch_string_unl_valid = '1' then
          state_next <= STATE_DONE;
        end if;

      when STATE_DONE =>
        -- Done: the kernel is done with its job.
        done <= '1';
        busy <= '0';
        idle <= '1';
        
        -- Wait for the reset signal (typically controlled by the host-side 
        -- software), so we can go to idle again. This reset is not to be
        -- confused with the system-wide reset that travels into the kernel
        -- alongside the clock (kcd_reset).        
    end case;
  end process;


 -- Sequential part:
  sequential_proc: process (kcd_clk)
  begin
    -- On the rising edge of the kernel clock:
    if rising_edge(kcd_clk) then
      -- Register the next state.
      state <= state_next;        

      -- Store the result when the cumputation finished
      if state = STATE_DONE then
        result <= sum_out_data;
      else
        result <= (63 downto state_slv'length => '0') & state_slv;
      end if;

      if kcd_reset = '1' or reset = '1' then
        state <= STATE_IDLE;
        result <= (others => '0');
      end if;
    end if;
  end process;
end architecture;
