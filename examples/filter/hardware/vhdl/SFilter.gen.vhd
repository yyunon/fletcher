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
begin
end architecture;
