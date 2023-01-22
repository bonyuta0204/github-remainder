{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import           Control.Monad.Trans.Except
import           Data.Text.IO               as TIO
import           Lib                        (filterConfilctPulls, formatPulls,
                                             getRepoByEnv, getToken,
                                             listOpenPullDetails)


main :: IO ()
main = do
  token <- getToken
  repo <- getRepoByEnv
  case repo of
    Nothing -> print "couldn't get repository"
    Just r -> do
      pulls <- runExceptT $ listOpenPullDetails token r
      let pullText =  formatPulls <$> fmap filterConfilctPulls pulls
      case pullText of
         Left e  -> print e
         Right t -> TIO.putStr t
