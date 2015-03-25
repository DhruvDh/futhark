-- | Futhark Compiler Driver
module Main (main) where

import Data.Version
import System.Console.GetOpt
import System.Exit (exitSuccess)

import Futhark.Passes
import Futhark.Actions
import Futhark.Compiler
import Futhark.Util.Options
import Futhark.Pipeline

import Futhark.Version

type FutharkOption = FunOptDescr FutharkConfig

passoption :: String -> Pass -> String -> [String] -> FutharkOption
passoption desc pass short long =
  Option short long
  (NoArg $ Right $ \opts -> opts { futharkpipeline = pass : futharkpipeline opts })
  desc

commandLineOptions :: [FutharkOption]
commandLineOptions =
  [ Option "v" ["version"]
    (NoArg $ Left $ do putStrLn $ "Futhark " ++ showVersion version
                       putStrLn "(C) HIPERFIT research centre"
                       putStrLn "Department of Computer Science, University of Copenhagen (DIKU)"
                       exitSuccess)
    "Print version information and exit."
  , Option "V" ["verbose"]
    (OptArg (\file -> Right $ \opts -> opts { futharkverbose = Just file }) "FILE")
    "Print verbose output on standard error; wrong program to FILE."
  , Option [] ["inhibit-uniqueness-checking"]
    (NoArg $ Right $ \opts -> opts { futharkcheckAliases = False })
    "Don't check that uniqueness constraints are being upheld."
  , Option [] ["compile-sequential"]
    (NoArg $ Right $ \opts -> opts { futharkaction = seqCodegenAction })
    "Translate program into sequential C and write it on standard output."
  , Option [] ["generate-flow-graph"]
    (NoArg $ Right $ \opts -> opts { futharkaction = flowGraphAction })
    "Print the SOAC flow graph of the final program."
  , Option [] ["compile-imperative"]
    (NoArg $ Right $ \opts -> opts { futharkaction = impCodeGenAction })
    "Translate program into the imperative IL and write it on standard output."
  , Option "p" ["print"]
    (NoArg $ Right $ \opts -> opts { futharkaction = printAction })
    "Prettyprint the resulting internal representation on standard output (default action)."
  , Option "i" ["interpret"]
    (NoArg $ Right $ \opts -> opts { futharkaction = interpretAction' })
    "Run the program via an interpreter."
  , Option [] ["externalise"]
    (NoArg $ Right $ \opts -> opts { futharkaction = externaliseAction})
    "Prettyprint the resulting external representation on standard output."
  , Option [] ["no-bounds-checking"]
    (NoArg $ Right $ \opts -> opts { futharkboundsCheck = False })
    "Do not perform bounds checking in the generated program."
  , passoption "Remove debugging annotations from program." uttransform
    "u" ["untrace"]
  , passoption "Transform all second-order array combinators to for-loops." fotransform
    "f" ["first-order-transform"]
  , passoption "Transform program to explicit memory representation" explicitMemory
    "a" ["explicit-allocations"]
  , passoption "Perform simple enabling optimisations." eotransform
    "e" ["enabling-optimisations"]
  , passoption "Perform higher-order optimisation, i.e., fusion." hotransform
    "h" ["higher-order-optimizations"]
  , passoption "Aggressively inline and remove dead functions." inlinetransform
    [] ["inline-functions"]
  , passoption "Remove dead functions." removeDeadFunctions
    [] ["remove-dead-functions"]
  , passoption "Optimise predicates" optimisePredicates
    [] ["optimise-predicates"]
  , passoption "Optimise shape computation" optimiseShapes
    [] ["optimise-shapes"]
  , passoption "Lower in-place updates" inPlaceLowering
    [] ["in-place-lowering"]
  , passoption "Common subexpression elimination" commonSubexpressionElimination
    [] ["cse"]
  , Option "s" ["standard"]
    (NoArg $ Right $ \opts -> opts { futharkpipeline = standardPipeline ++ futharkpipeline opts })
    "Use the recommended optimised pipeline."
  ]

standardPipeline :: [Pass]
standardPipeline =
  [ uttransform
  , eotransform
  , inlinetransform
  , commonSubexpressionElimination
  , eotransform
  , hotransform
  , commonSubexpressionElimination
  , eotransform
  , removeDeadFunctions
  ]

-- | Entry point.  Non-interactive, except when reading interpreter
-- input from standard input.
main :: IO ()
main = mainWithOptions newFutharkConfig commandLineOptions compile
  where compile [file] config = Just $ runCompilerOnProgram config file
        compile _      _      = Nothing
