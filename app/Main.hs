{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import           Data.Text.IO as TIO
import           Format       (pullToRichBlock, pullsToText)
import           GitHubClient (runListUnMergeablePulls)
import           SlackClient


main :: IO ()
main = do
  pulls <- runListUnMergeablePulls
  webhookURL <- getWebHookRequest
  case pulls of
    Left err -> print err
    Right ps -> do
      TIO.putStr $ pullsToText ps
      case webhookURL of
        Nothing -> print "$WEBHOOK_URL is not set"
        Just url -> postWebhook url $ SlackMessage {
        text=Nothing
        ,blocks=Just $  Section  (TextContent $ MarkdownText "以下のPRがコンフリクトしています")  : map pullToRichBlock ps
        }
