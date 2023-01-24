{-# LANGUAGE OverloadedStrings #-}

module SlackClient
  ( postWebhook,
    getWebHookRequest,
    SlackMessage(..),
    Block(..),
    TextItem(..),
    BlockContents(..)
  )
where

import           Data.Aeson
import qualified Data.Text           as T
import           Network.HTTP.Simple
import           System.Environment



data SlackMessage = SlackMessage
  { text   :: Maybe T.Text,
    blocks :: Maybe [Block]
  } deriving (Show)


data TextItem = PlainText T.Text | MarkdownText T.Text deriving (Show)

data BlockContents = TextContent TextItem | FieldsContent [TextItem] deriving (Show)

newtype Block = Section BlockContents deriving (Show)

instance ToJSON TextItem where
  toJSON (PlainText text) = object ["text" .= text, ("type","plain_text")]
  toJSON (MarkdownText text) = object ["text" .= text, ("type","mrkdwn")]

instance ToJSON BlockContents where
  toJSON (TextContent textItem)  = object ["text" .= textItem]
  toJSON (FieldsContent textItems)  = object ["fields" .= textItems]

instance ToJSON Block where
  toJSON (Section (TextContent textItem)) = object [("type" ,"section"), "text" .= textItem]
  toJSON (Section (FieldsContent textItems)) = object [("type" ,"section"), "fields" .= textItems]

instance ToJSON SlackMessage where
  toJSON (SlackMessage {text = t,blocks=bl}) = object ["text" .= t, "blocks" .= bl]

postWebhook :: String -> SlackMessage -> IO ()
postWebhook url message = do
  let request = parseRequest url
  case request of
    Nothing -> print "Webhook URL is not valid."
    Just req -> do
      let r = setRequestBodyJSON message $ setRequestMethod "POST" req
      _ <- httpLbs r
      return ()

getWebHookRequest :: IO (Maybe String)
getWebHookRequest = lookupEnv "WEBHOOK_URL"
