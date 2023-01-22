{-# LANGUAGE OverloadedStrings #-}

module SlackClient
  ( postWebhook,
    postTest,
  )
where

import           Data.Aeson
import qualified Data.Text           as T
import           Network.HTTP.Simple
import           System.Environment



data SlackMessage = SlackMessage
  { text :: T.Text
  }

instance ToJSON SlackMessage where
  toJSON (SlackMessage text) = object ["text" .= text]

postWebhook :: String -> SlackMessage -> IO ()
postWebhook url message = do
  let request = parseRequest url
  case request of
    Nothing -> print "Webhook URL is not valid."
    Just req -> do
      let r = setRequestBodyJSON message $ setRequestMethod "POST" req

      res <- httpLbs r
      print res

postTest :: IO ()
postTest = do
  url <- getWebHookRequest
  case url of
    Nothing -> print "nothing"
    Just u  -> postWebhook u (SlackMessage "Hello, World")

getWebHookRequest :: IO (Maybe String)
getWebHookRequest = lookupEnv "WEBHOOK_URL"
