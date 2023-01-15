{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Lib (getToken, listPulls)

main :: IO ()
main = do
  token <- getToken
  pulls <- listPulls token "bonyuta0204" "rails-vue-playground"
  print pulls
