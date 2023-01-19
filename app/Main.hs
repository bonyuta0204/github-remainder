{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Lib (getToken, listOpenPullDetails,filterConfilctPulls)
import Control.Monad.Trans.Except

main :: IO ()
main = do
  token <- getToken
  pulls <- runExceptT $  listOpenPullDetails token "bonyuta0204" "dotfiles"
  print $ fmap filterConfilctPulls pulls

