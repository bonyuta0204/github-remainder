{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Lib (listUsers)

main :: IO ()
main = do
  user <- listUsers "bonyuta0204"
  print user
