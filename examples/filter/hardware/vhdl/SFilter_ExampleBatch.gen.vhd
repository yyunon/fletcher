-- Copyright 2018-2019 Delft University of Technology
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- This file was generated by Fletchgen. Modify this file at your own risk.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Array_pkg.all;

entity SFilter_ExampleBatch is
  generic (
    INDEX_WIDTH                            : integer := 32;
    TAG_WIDTH                              : integer := 1;
    EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH     : integer := 64;
    EXAMPLEBATCH_STRING_BUS_DATA_WIDTH     : integer := 512;
    EXAMPLEBATCH_STRING_BUS_LEN_WIDTH      : integer := 8;
    EXAMPLEBATCH_STRING_BUS_BURST_STEP_LEN : integer := 1;
    EXAMPLEBATCH_STRING_BUS_BURST_MAX_LEN  : integer := 16;
    EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH     : integer := 64;
    EXAMPLEBATCH_NUMBER_BUS_DATA_WIDTH     : integer := 512;
    EXAMPLEBATCH_NUMBER_BUS_LEN_WIDTH      : integer := 8;
    EXAMPLEBATCH_NUMBER_BUS_BURST_STEP_LEN : integer := 1;
    EXAMPLEBATCH_NUMBER_BUS_BURST_MAX_LEN  : integer := 16
  );
  port (
    bcd_clk                            : in  std_logic;
    bcd_reset                          : in  std_logic;
    kcd_clk                            : in  std_logic;
    kcd_reset                          : in  std_logic;
    ExampleBatch_string_valid          : out std_logic;
    ExampleBatch_string_ready          : in  std_logic;
    ExampleBatch_string_dvalid         : out std_logic;
    ExampleBatch_string_last           : out std_logic;
    ExampleBatch_string_length         : out std_logic_vector(31 downto 0);
    ExampleBatch_string_count          : out std_logic_vector(0 downto 0);
    ExampleBatch_string_chars_valid    : out std_logic;
    ExampleBatch_string_chars_ready    : in  std_logic;
    ExampleBatch_string_chars_dvalid   : out std_logic;
    ExampleBatch_string_chars_last     : out std_logic;
    ExampleBatch_string_chars          : out std_logic_vector(159 downto 0);
    ExampleBatch_string_chars_count    : out std_logic_vector(4 downto 0);
    ExampleBatch_string_bus_rreq_valid : out std_logic;
    ExampleBatch_string_bus_rreq_ready : in  std_logic;
    ExampleBatch_string_bus_rreq_addr  : out std_logic_vector(EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH-1 downto 0);
    ExampleBatch_string_bus_rreq_len   : out std_logic_vector(EXAMPLEBATCH_STRING_BUS_LEN_WIDTH-1 downto 0);
    ExampleBatch_string_bus_rdat_valid : in  std_logic;
    ExampleBatch_string_bus_rdat_ready : out std_logic;
    ExampleBatch_string_bus_rdat_data  : in  std_logic_vector(EXAMPLEBATCH_STRING_BUS_DATA_WIDTH-1 downto 0);
    ExampleBatch_string_bus_rdat_last  : in  std_logic;
    ExampleBatch_string_cmd_valid      : in  std_logic;
    ExampleBatch_string_cmd_ready      : out std_logic;
    ExampleBatch_string_cmd_firstIdx   : in  std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_string_cmd_lastIdx    : in  std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_string_cmd_ctrl       : in  std_logic_vector(EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH*2-1 downto 0);
    ExampleBatch_string_cmd_tag        : in  std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_string_unl_valid      : out std_logic;
    ExampleBatch_string_unl_ready      : in  std_logic;
    ExampleBatch_string_unl_tag        : out std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_number_valid          : out std_logic;
    ExampleBatch_number_ready          : in  std_logic;
    ExampleBatch_number_dvalid         : out std_logic;
    ExampleBatch_number_last           : out std_logic;
    ExampleBatch_number                : out std_logic_vector(63 downto 0);
    ExampleBatch_number_bus_rreq_valid : out std_logic;
    ExampleBatch_number_bus_rreq_ready : in  std_logic;
    ExampleBatch_number_bus_rreq_addr  : out std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH-1 downto 0);
    ExampleBatch_number_bus_rreq_len   : out std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_LEN_WIDTH-1 downto 0);
    ExampleBatch_number_bus_rdat_valid : in  std_logic;
    ExampleBatch_number_bus_rdat_ready : out std_logic;
    ExampleBatch_number_bus_rdat_data  : in  std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_DATA_WIDTH-1 downto 0);
    ExampleBatch_number_bus_rdat_last  : in  std_logic;
    ExampleBatch_number_cmd_valid      : in  std_logic;
    ExampleBatch_number_cmd_ready      : out std_logic;
    ExampleBatch_number_cmd_firstIdx   : in  std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_lastIdx    : in  std_logic_vector(INDEX_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_ctrl       : in  std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH-1 downto 0);
    ExampleBatch_number_cmd_tag        : in  std_logic_vector(TAG_WIDTH-1 downto 0);
    ExampleBatch_number_unl_valid      : out std_logic;
    ExampleBatch_number_unl_ready      : in  std_logic;
    ExampleBatch_number_unl_tag        : out std_logic_vector(TAG_WIDTH-1 downto 0)
  );
end entity;

architecture Implementation of SFilter_ExampleBatch is
  signal string_inst_bcd_clk        : std_logic;
  signal string_inst_bcd_reset      : std_logic;

  signal string_inst_kcd_clk        : std_logic;
  signal string_inst_kcd_reset      : std_logic;

  signal string_inst_cmd_valid      : std_logic;
  signal string_inst_cmd_ready      : std_logic;
  signal string_inst_cmd_firstIdx   : std_logic_vector(INDEX_WIDTH-1 downto 0);
  signal string_inst_cmd_lastIdx    : std_logic_vector(INDEX_WIDTH-1 downto 0);
  signal string_inst_cmd_ctrl       : std_logic_vector(EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH*2-1 downto 0);
  signal string_inst_cmd_tag        : std_logic_vector(TAG_WIDTH-1 downto 0);

  signal string_inst_unl_valid      : std_logic;
  signal string_inst_unl_ready      : std_logic;
  signal string_inst_unl_tag        : std_logic_vector(TAG_WIDTH-1 downto 0);

  signal string_inst_bus_rreq_valid : std_logic;
  signal string_inst_bus_rreq_ready : std_logic;
  signal string_inst_bus_rreq_addr  : std_logic_vector(EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH-1 downto 0);
  signal string_inst_bus_rreq_len   : std_logic_vector(EXAMPLEBATCH_STRING_BUS_LEN_WIDTH-1 downto 0);
  signal string_inst_bus_rdat_valid : std_logic;
  signal string_inst_bus_rdat_ready : std_logic;
  signal string_inst_bus_rdat_data  : std_logic_vector(EXAMPLEBATCH_STRING_BUS_DATA_WIDTH-1 downto 0);
  signal string_inst_bus_rdat_last  : std_logic;

  signal string_inst_out_valid      : std_logic_vector(1 downto 0);
  signal string_inst_out_ready      : std_logic_vector(1 downto 0);
  signal string_inst_out_data       : std_logic_vector(197 downto 0);
  signal string_inst_out_dvalid     : std_logic_vector(1 downto 0);
  signal string_inst_out_last       : std_logic_vector(1 downto 0);

  signal number_inst_bcd_clk        : std_logic;
  signal number_inst_bcd_reset      : std_logic;

  signal number_inst_kcd_clk        : std_logic;
  signal number_inst_kcd_reset      : std_logic;

  signal number_inst_cmd_valid      : std_logic;
  signal number_inst_cmd_ready      : std_logic;
  signal number_inst_cmd_firstIdx   : std_logic_vector(INDEX_WIDTH-1 downto 0);
  signal number_inst_cmd_lastIdx    : std_logic_vector(INDEX_WIDTH-1 downto 0);
  signal number_inst_cmd_ctrl       : std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH-1 downto 0);
  signal number_inst_cmd_tag        : std_logic_vector(TAG_WIDTH-1 downto 0);

  signal number_inst_unl_valid      : std_logic;
  signal number_inst_unl_ready      : std_logic;
  signal number_inst_unl_tag        : std_logic_vector(TAG_WIDTH-1 downto 0);

  signal number_inst_bus_rreq_valid : std_logic;
  signal number_inst_bus_rreq_ready : std_logic;
  signal number_inst_bus_rreq_addr  : std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH-1 downto 0);
  signal number_inst_bus_rreq_len   : std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_LEN_WIDTH-1 downto 0);
  signal number_inst_bus_rdat_valid : std_logic;
  signal number_inst_bus_rdat_ready : std_logic;
  signal number_inst_bus_rdat_data  : std_logic_vector(EXAMPLEBATCH_NUMBER_BUS_DATA_WIDTH-1 downto 0);
  signal number_inst_bus_rdat_last  : std_logic;

  signal number_inst_out_valid      : std_logic_vector(0 downto 0);
  signal number_inst_out_ready      : std_logic_vector(0 downto 0);
  signal number_inst_out_data       : std_logic_vector(63 downto 0);
  signal number_inst_out_dvalid     : std_logic_vector(0 downto 0);
  signal number_inst_out_last       : std_logic_vector(0 downto 0);

begin
  string_inst : ArrayReader
    generic map (
      BUS_ADDR_WIDTH     => EXAMPLEBATCH_STRING_BUS_ADDR_WIDTH,
      BUS_DATA_WIDTH     => EXAMPLEBATCH_STRING_BUS_DATA_WIDTH,
      BUS_LEN_WIDTH      => EXAMPLEBATCH_STRING_BUS_LEN_WIDTH,
      BUS_BURST_STEP_LEN => EXAMPLEBATCH_STRING_BUS_BURST_STEP_LEN,
      BUS_BURST_MAX_LEN  => EXAMPLEBATCH_STRING_BUS_BURST_MAX_LEN,
      INDEX_WIDTH        => INDEX_WIDTH,
      CFG                => "listprim(8;epc=20)",
      CMD_TAG_ENABLE     => true,
      CMD_TAG_WIDTH      => TAG_WIDTH
    )
    port map (
      bcd_clk        => string_inst_bcd_clk,
      bcd_reset      => string_inst_bcd_reset,
      kcd_clk        => string_inst_kcd_clk,
      kcd_reset      => string_inst_kcd_reset,
      cmd_valid      => string_inst_cmd_valid,
      cmd_ready      => string_inst_cmd_ready,
      cmd_firstIdx   => string_inst_cmd_firstIdx,
      cmd_lastIdx    => string_inst_cmd_lastIdx,
      cmd_ctrl       => string_inst_cmd_ctrl,
      cmd_tag        => string_inst_cmd_tag,
      unl_valid      => string_inst_unl_valid,
      unl_ready      => string_inst_unl_ready,
      unl_tag        => string_inst_unl_tag,
      bus_rreq_valid => string_inst_bus_rreq_valid,
      bus_rreq_ready => string_inst_bus_rreq_ready,
      bus_rreq_addr  => string_inst_bus_rreq_addr,
      bus_rreq_len   => string_inst_bus_rreq_len,
      bus_rdat_valid => string_inst_bus_rdat_valid,
      bus_rdat_ready => string_inst_bus_rdat_ready,
      bus_rdat_data  => string_inst_bus_rdat_data,
      bus_rdat_last  => string_inst_bus_rdat_last,
      out_valid      => string_inst_out_valid,
      out_ready      => string_inst_out_ready,
      out_data       => string_inst_out_data,
      out_dvalid     => string_inst_out_dvalid,
      out_last       => string_inst_out_last
    );

  number_inst : ArrayReader
    generic map (
      BUS_ADDR_WIDTH     => EXAMPLEBATCH_NUMBER_BUS_ADDR_WIDTH,
      BUS_DATA_WIDTH     => EXAMPLEBATCH_NUMBER_BUS_DATA_WIDTH,
      BUS_LEN_WIDTH      => EXAMPLEBATCH_NUMBER_BUS_LEN_WIDTH,
      BUS_BURST_STEP_LEN => EXAMPLEBATCH_NUMBER_BUS_BURST_STEP_LEN,
      BUS_BURST_MAX_LEN  => EXAMPLEBATCH_NUMBER_BUS_BURST_MAX_LEN,
      INDEX_WIDTH        => INDEX_WIDTH,
      CFG                => "prim(64)",
      CMD_TAG_ENABLE     => true,
      CMD_TAG_WIDTH      => TAG_WIDTH
    )
    port map (
      bcd_clk        => number_inst_bcd_clk,
      bcd_reset      => number_inst_bcd_reset,
      kcd_clk        => number_inst_kcd_clk,
      kcd_reset      => number_inst_kcd_reset,
      cmd_valid      => number_inst_cmd_valid,
      cmd_ready      => number_inst_cmd_ready,
      cmd_firstIdx   => number_inst_cmd_firstIdx,
      cmd_lastIdx    => number_inst_cmd_lastIdx,
      cmd_ctrl       => number_inst_cmd_ctrl,
      cmd_tag        => number_inst_cmd_tag,
      unl_valid      => number_inst_unl_valid,
      unl_ready      => number_inst_unl_ready,
      unl_tag        => number_inst_unl_tag,
      bus_rreq_valid => number_inst_bus_rreq_valid,
      bus_rreq_ready => number_inst_bus_rreq_ready,
      bus_rreq_addr  => number_inst_bus_rreq_addr,
      bus_rreq_len   => number_inst_bus_rreq_len,
      bus_rdat_valid => number_inst_bus_rdat_valid,
      bus_rdat_ready => number_inst_bus_rdat_ready,
      bus_rdat_data  => number_inst_bus_rdat_data,
      bus_rdat_last  => number_inst_bus_rdat_last,
      out_valid      => number_inst_out_valid,
      out_ready      => number_inst_out_ready,
      out_data       => number_inst_out_data,
      out_dvalid     => number_inst_out_dvalid,
      out_last       => number_inst_out_last
    );

  ExampleBatch_string_valid          <= string_inst_out_valid(0);
  ExampleBatch_string_chars_valid    <= string_inst_out_valid(1);
  string_inst_out_ready(0)           <= ExampleBatch_string_ready;
  string_inst_out_ready(1)           <= ExampleBatch_string_chars_ready;
  ExampleBatch_string_dvalid         <= string_inst_out_dvalid(0);
  ExampleBatch_string_chars_dvalid   <= string_inst_out_dvalid(1);
  ExampleBatch_string_last           <= string_inst_out_last(0);
  ExampleBatch_string_chars_last     <= string_inst_out_last(1);
  ExampleBatch_string_length         <= string_inst_out_data(31 downto 0);
  ExampleBatch_string_count          <= string_inst_out_data(32 downto 32);
  ExampleBatch_string_chars          <= string_inst_out_data(192 downto 33);
  ExampleBatch_string_chars_count    <= string_inst_out_data(197 downto 193);

  ExampleBatch_string_bus_rreq_valid <= string_inst_bus_rreq_valid;
  string_inst_bus_rreq_ready         <= ExampleBatch_string_bus_rreq_ready;
  ExampleBatch_string_bus_rreq_addr  <= string_inst_bus_rreq_addr;
  ExampleBatch_string_bus_rreq_len   <= string_inst_bus_rreq_len;
  string_inst_bus_rdat_valid         <= ExampleBatch_string_bus_rdat_valid;
  ExampleBatch_string_bus_rdat_ready <= string_inst_bus_rdat_ready;
  string_inst_bus_rdat_data          <= ExampleBatch_string_bus_rdat_data;
  string_inst_bus_rdat_last          <= ExampleBatch_string_bus_rdat_last;

  ExampleBatch_string_unl_valid      <= string_inst_unl_valid;
  string_inst_unl_ready              <= ExampleBatch_string_unl_ready;
  ExampleBatch_string_unl_tag        <= string_inst_unl_tag;

  ExampleBatch_number_valid          <= number_inst_out_valid(0);
  number_inst_out_ready(0)           <= ExampleBatch_number_ready;
  ExampleBatch_number_dvalid         <= number_inst_out_dvalid(0);
  ExampleBatch_number_last           <= number_inst_out_last(0);
  ExampleBatch_number                <= number_inst_out_data;

  ExampleBatch_number_bus_rreq_valid <= number_inst_bus_rreq_valid;
  number_inst_bus_rreq_ready         <= ExampleBatch_number_bus_rreq_ready;
  ExampleBatch_number_bus_rreq_addr  <= number_inst_bus_rreq_addr;
  ExampleBatch_number_bus_rreq_len   <= number_inst_bus_rreq_len;
  number_inst_bus_rdat_valid         <= ExampleBatch_number_bus_rdat_valid;
  ExampleBatch_number_bus_rdat_ready <= number_inst_bus_rdat_ready;
  number_inst_bus_rdat_data          <= ExampleBatch_number_bus_rdat_data;
  number_inst_bus_rdat_last          <= ExampleBatch_number_bus_rdat_last;

  ExampleBatch_number_unl_valid      <= number_inst_unl_valid;
  number_inst_unl_ready              <= ExampleBatch_number_unl_ready;
  ExampleBatch_number_unl_tag        <= number_inst_unl_tag;

  string_inst_bcd_clk           <= bcd_clk;
  string_inst_bcd_reset         <= bcd_reset;

  string_inst_kcd_clk           <= kcd_clk;
  string_inst_kcd_reset         <= kcd_reset;

  string_inst_cmd_valid         <= ExampleBatch_string_cmd_valid;
  ExampleBatch_string_cmd_ready <= string_inst_cmd_ready;
  string_inst_cmd_firstIdx      <= ExampleBatch_string_cmd_firstIdx;
  string_inst_cmd_lastIdx       <= ExampleBatch_string_cmd_lastIdx;
  string_inst_cmd_ctrl          <= ExampleBatch_string_cmd_ctrl;
  string_inst_cmd_tag           <= ExampleBatch_string_cmd_tag;

  number_inst_bcd_clk           <= bcd_clk;
  number_inst_bcd_reset         <= bcd_reset;

  number_inst_kcd_clk           <= kcd_clk;
  number_inst_kcd_reset         <= kcd_reset;

  number_inst_cmd_valid         <= ExampleBatch_number_cmd_valid;
  ExampleBatch_number_cmd_ready <= number_inst_cmd_ready;
  number_inst_cmd_firstIdx      <= ExampleBatch_number_cmd_firstIdx;
  number_inst_cmd_lastIdx       <= ExampleBatch_number_cmd_lastIdx;
  number_inst_cmd_ctrl          <= ExampleBatch_number_cmd_ctrl;
  number_inst_cmd_tag           <= ExampleBatch_number_cmd_tag;

end architecture;
