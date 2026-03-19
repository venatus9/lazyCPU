import qualified Data.Map.Strict as M
import Data.Map.Strict (Map)
import Data.Word (Word8)
import Numeric (readHex, showHex)
import Data.Char (toUpper)
import Control.Monad (when)
import System.IO (hFlush, stdout)


-- ===== Memory setup =====
type Addr = Int
type Memory = Map Addr Word8

emptyMemory :: Memory
emptyMemory = M.empty

readMem :: Addr -> Memory -> Word8
readMem addr mem = M.findWithDefault 0 addr mem

writeMem :: Int -> Word8 -> Memory -> Memory
writeMem = M.insert

-- ===== CPU definition =====
data CPU = CPU
  { pc :: Addr       -- program counter
  , mem :: Memory    -- memory map
  , reg :: Word8     -- single register
  , halted :: Bool   -- halted flag
  }

-- CPU instance
cpu :: CPU
cpu = CPU
  { pc = 0
  , mem = emptyMemory
  , reg = 0
  , halted = False
  }

-- Mnemonic dictionary
type Dict k v = Map k v

mnemonicDict :: Dict String Word8
mnemonicDict = M.fromList
  [ ("SET", 0x01)
  , ("PNT", 0x02)
  , ("ADD", 0x03)
  , ("SUB", 0x04)
  , ("MUL", 0x05)
  , ("DIV", 0x06)
  , ("HLT", 0xFF)
  ]

lookupMnemonic :: String -> Maybe Word8
lookupMnemonic instr = M.lookup (map toUpper instr) mnemonicDict

-- Hex parsing
parseHex :: String -> Maybe Word8
parseHex str =
  case readHex str of
    [(val, "")] | val >= 0 && val <= 255 -> Just (fromIntegral val)
    _ -> Nothing

-- Instruction parsing
-- Returns (opcode, optional operand)
parseInstruction :: String -> Maybe (Word8, Maybe Word8)
parseInstruction line =
  case words line of
    [] -> Nothing
    (mnemonic:rest) -> do
      opcode <- lookupMnemonic mnemonic
      operand <- case rest of
        []      -> Just Nothing
        [opStr] -> parseHex (map toUpper opStr) >>= \v -> Just (Just v)
        _       -> Nothing
      return (opcode, operand)

-- Load memory from assembly input
loadMemoryASM :: Addr -> Memory -> IO Memory
loadMemoryASM addr mem = do
  putStr $ show addr ++ ". "
  hFlush stdout
  line <- getLine
  let line' = map toUpper line
  case parseInstruction line' of
    Nothing -> do
      putStrLn "Invalid instruction! Try again."
      loadMemoryASM addr mem
    Just (opcode, mOperand) -> do
      let mem1 = writeMem addr opcode mem
      case mOperand of
        Nothing ->
          if opcode == 0xFF  -- HLT
            then return mem1
            else loadMemoryASM (addr + 1) mem1
        Just op -> do
          let mem2 = writeMem (addr + 1) op mem1
          loadMemoryASM (addr + 2) mem2

-- helper function
printHex :: Word8 -> IO ()
printHex b = putStrLn $ let h = map toUpper (showHex b "") in if length h == 1 then '0':h else h

toHex :: Word8 -> String
toHex b = let h = map toUpper (showHex b "") in if length h == 1 then '0':h else h

-- Pretty print memory
printMemory :: Memory -> IO ()
printMemory mem = mapM_ printEntry (M.toAscList mem)
  where
    printEntry (addr, val) = putStrLn $ show addr ++ ": " ++ toHex val

execCPU :: CPU -> IO ()
execCPU cpu
  | halted cpu = putStrLn "\nEND CPU\n"
  | otherwise = do
      let opcode = readMem (pc cpu) (mem cpu)

      case opcode of

        0x01 -> do
          let val = readMem (pc cpu + 1) (mem cpu)
          let cpu' = cpu { reg = val, pc = pc cpu + 2 }
          execCPU cpu'

        0x02 -> do
          printHex (reg cpu)
          let cpu' = cpu { pc = pc cpu + 1 }
          execCPU cpu'

        0x03 -> do
          let val = readMem (pc cpu + 1) (mem cpu)
          let cpu' = cpu { reg = reg cpu + val, pc = pc cpu + 2 }
          execCPU cpu'

        0xFF -> do
          execCPU cpu { halted = True }

        _ -> do
          putStrLn $ "Unknown opcode: " ++ show opcode
          execCPU cpu { halted = True }

-- Main program
main :: IO ()
main = do
  putStrLn "Enter assembly instructions. HLT to stop\n"
  mem <- loadMemoryASM 0 M.empty
  putStrLn "\nMemory contents:"
  printMemory mem
  putStrLn "\nSTART CPU\n"
  let cpuStart = cpu { mem = mem }
  execCPU cpuStart
