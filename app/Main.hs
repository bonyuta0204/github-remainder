module Main (main) where

import           Data.Text.IO as TIO
import           Format       (pullsToText)
import           GitHubClient (runListUnMergeablePulls)
import           SlackClient  (postWebhook)


main :: IO ()
main = do
  pulls <- runListUnMergeablePulls
  case pulls of
    Left err -> print err
    Right ps -> TIO.putStr $ pullsToText ps
