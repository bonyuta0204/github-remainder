{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Monad.Trans.Except
import Data.Text.IO as TIO
import Lib (filterConfilctPulls, formatPulls, getToken, listOpenPullDetails)


main :: IO ()
main = do
  token <- getToken
  pulls <- runExceptT $ listOpenPullDetails token "bonyuta0204" "dotfiles"
  let pullText =  formatPulls <$> fmap filterConfilctPulls pulls
  case pullText of
     Left e -> print e
     Right t -> TIO.putStr t
