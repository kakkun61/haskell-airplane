module Main where

import Control.Monad.Result

main :: IO ()
main = do
  putStrLn "Example"
  print $ runResult doSomething

doSomething :: MonadFail m => m Int
doSomething = fail "fail"
