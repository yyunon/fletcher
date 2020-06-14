library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.Stream_pkg.all;


entity FilterStream is
  generic (
    
    -- Width of the stream data vector.
    LANE_COUNT                  : natural := 1;
    
    -- Width of the transaction index.
    INDEX_WIDTH                 : natural;
    
    -- Width of the stream data vector.
    DIMENSIONALITY              : natural := 1;
    
    -- Minimum depth of the transaction buffer
    MIN_BUFFER_DEPTH            : natural := 1

  );
  port (

    -- Rising-edge sensitive clock.
    clk                                 : in  std_logic;

    -- Active-high synchronous reset.
    reset                               : in  std_logic;

    -- Input stream.
    in_valid                            : in  std_logic;
    in_ready                            : out std_logic;
    in_last                             : in  std_logic_vector(DIMENSIONALITY-1 downto 0);
    
    -- Predicate boolean stream.
    pred_in_valid                       : in  std_logic;
    pred_in_ready                       : out std_logic;
    pred_in_data                        : in  std_logic_vector(LANE_COUNT-1 downto 0);
    
    -- Output stream.
    out_valid                           : out std_logic;
    out_ready                           : in  std_logic;
    out_strb                            : out std_logic_vector(LANE_COUNT-1 downto 0);
    out_last                            : out std_logic_vector(LANE_COUNT*DIMENSIONALITY-1 downto 0)
  );
end FilterStream;

architecture Behavioral of FilterStream is

   signal in_ready_s                    : std_logic;
   
   signal pred_transation_counter       : unsigned(INDEX_WIDTH-1 downto 0);
   signal pred_transation_counter_next  : unsigned(INDEX_WIDTH-1 downto 0);
   signal pred_index                    : std_logic_vector(INDEX_WIDTH-1 downto 0);
   
   signal in_transation_counter         : unsigned(INDEX_WIDTH-1 downto 0);
   signal in_transation_counter_next    : unsigned(INDEX_WIDTH-1 downto 0);
   signal in_index                      : std_logic_vector(INDEX_WIDTH-1 downto 0);
   
   signal pred_b_in_data                : std_logic_vector(LANE_COUNT + INDEX_WIDTH-1 downto 0);
   signal pred_b_in_ready               : std_logic;
   signal pred_b_in_valid               : std_logic;
   
   signal pred_b_out_valid              : std_logic;
   signal pred_b_out_ready              : std_logic;
   signal pred_b_out_data               : std_logic_vector(LANE_COUNT + INDEX_WIDTH-1 downto 0);
begin
    
  -- Buffer to hold predicated as transation indexes  
  pred_buffer: StreamBuffer
    generic map (
      MIN_DEPTH                 => MIN_BUFFER_DEPTH,
      DATA_WIDTH                => INDEX_WIDTH + LANE_COUNT
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => pred_b_in_valid,
      in_ready                  => pred_b_in_ready,
      in_data                   => pred_b_in_data,
      out_valid                 => pred_b_out_valid,
      out_ready                 => pred_b_out_ready,
      out_data                  => pred_b_out_data
    );
    
    --In the predicate buffer we store the index of the transaction that has
    --data inside that needs passing through.
    pred_b_in_data <= std_logic_vector(pred_in_data & std_logic_vector(pred_transation_counter_next));
    pred_in_ready <= pred_b_in_ready;
    
    
    comb_proc: process (out_ready, pred_b_out_valid, in_transation_counter, pred_b_out_data,
                       pred_transation_counter, pred_in_valid, pred_b_in_ready, in_valid, in_ready_s,
                       in_last, pred_in_data) is
        variable hit               : boolean;
        variable current_index     : unsigned(INDEX_WIDTH-1 downto 0);
      begin
        pred_b_in_valid <= '0';
        pred_b_out_ready <= '0';
        out_valid <= '0';
        
        in_ready_s <= out_ready and pred_b_out_valid;
        out_strb <= pred_b_out_data(INDEX_WIDTH + LANE_COUNT - 1 downto INDEX_WIDTH);
        
        --Retain counters by default.
        pred_transation_counter_next <= pred_transation_counter;
        in_transation_counter_next <= in_transation_counter;
         
        current_index := in_transation_counter + 1;
        hit := current_index = unsigned(pred_b_out_data(INDEX_WIDTH-1 downto 0));
       
        if pred_in_valid = '1' and pred_b_in_ready = '1' then
         pred_transation_counter_next <= pred_transation_counter + 1;
        end if;
        
        if in_valid = '1' and in_ready_s = '1' then
         in_transation_counter_next <= current_index;
         if hit then
           out_valid <= '1';
           --pred_b_out_ready <= '1';
         end if;
         if or_reduce(in_last) = '1' then
           out_valid <= '1';
           out_strb <= (others => '0');
           --Reset counters.
           in_transation_counter_next <= to_unsigned(0, INDEX_WIDTH);
           pred_transation_counter_next <= to_unsigned(0, INDEX_WIDTH);
         end if;
        end if;
        
        if pred_in_valid = '1' and pred_b_in_ready = '1' and or_reduce(pred_in_data) = '1' then
          pred_b_in_valid <= '1';
        end if;
        
        if hit and out_ready <= '1' then
          pred_b_out_ready <= '1';
        end if;    
      end process;
       
    reg_proc: process(clk) is
      begin
        if rising_edge(clk) then
          pred_transation_counter <= pred_transation_counter_next;
          in_transation_counter   <= in_transation_counter_next;
          if reset = '1' then
            in_transation_counter <= to_unsigned(0, INDEX_WIDTH);
            pred_transation_counter <= to_unsigned(0, INDEX_WIDTH);
          end if;
        end if;
    end process;
    
    in_ready <= in_ready_s;
    out_last <= in_last;
    
  
end Behavioral;
