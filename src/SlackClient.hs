{-# LANGUAGE OverloadedStrings #-}

module SlackClient
  ( postWebhook,
    postTest,
    getWebHookRequest,
    printBlockText,
    SlackMessage(..),
    Block(..),
    BlockType(..),
    BlockText(..),
    BlockTextType(..)
  )
where

import           Data.Aeson
import qualified Data.Text           as T
import           Network.HTTP.Simple
import           System.Environment



data SlackMessage = SlackMessage
  { text   :: T.Text,
    blocks :: [Block]
  }

data BlockType = Section

data BlockTextType = Markdown | PlainText

data BlockText = BlockText
  {
  blockTextType :: BlockTextType,
  blockTextText :: T.Text
  }

data Block = Block
  {
   blockType :: BlockType,
   blockText :: BlockText
  }

instance ToJSON SlackMessage where
  toJSON (SlackMessage text blocks) = object ["text" .= text, "blocks" .= blocks]


instance ToJSON BlockType where
  toJSON Section = "section"

instance ToJSON BlockTextType where
  toJSON Markdown  = "mrkdwn"
  toJSON PlainText = "plain_text"

instance ToJSON BlockText where
  toJSON BlockText{blockTextType = textType,blockTextText = t} = object ["type" .= textType,"text" .= t]

instance ToJSON Block where
  toJSON Block{blockType=blockType,blockText=blockText} = object ["type" .= blockType,"text" .= blockText]

printBlockText :: IO()
printBlockText = print $ encode $ Block {blockText = BlockText {blockTextType = Markdown,blockTextText = "hogehoge"},blockType = Section}

postWebhook :: String -> SlackMessage -> IO ()
postWebhook url message = do
  let request = parseRequest url
  case request of
    Nothing -> print "Webhook URL is not valid."
    Just req -> do
      let r = setRequestBodyJSON message $ setRequestMethod "POST" req
      _ <- httpLbs r
      return ()

postTest :: IO ()
postTest = do
  url <- getWebHookRequest
  case url of
    Nothing -> print "nothing"
    Just u  -> postWebhook u (SlackMessage {text="Hello, World",blocks=[Block { blockText = BlockText {blockTextType = Markdown,blockTextText = "hogehoge"},blockType = Section  }]})

getWebHookRequest :: IO (Maybe String)
getWebHookRequest = lookupEnv "WEBHOOK_URL"
