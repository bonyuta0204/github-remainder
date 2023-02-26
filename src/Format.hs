{-# LANGUAGE OverloadedStrings #-}

module Format
  (
  pullToText,
  pullsToText,
  pullToBlock,
  pullToRichBlock
  )
where

import qualified Data.Text   as T
import qualified GitHub      as GH
import           SlackClient


pullToText :: GH.PullRequest -> T.Text
pullToText pull = T.pack $ "#" ++ issueNumber ++ " " ++ title ++ "\n" ++ url ++ "\n"
  where title = T.unpack $ GH.pullRequestTitle pull
        url = T.unpack $ GH.getUrl $ GH.pullRequestHtmlUrl pull
        issueNumber = show $ GH.unIssueNumber $ GH.pullRequestNumber pull

pullsToText :: [GH.PullRequest] -> T.Text
pullsToText pulls = T.intercalate "\n" $ fmap pullToText pulls

pullToBlock :: GH.PullRequest -> Block
pullToBlock pull = Section $ TextContent $ MarkdownText $ T.pack $ buildAnchorLink url ("#" ++ issueNumber ++ " " ++ title)
  where title = T.unpack $ GH.pullRequestTitle pull
        url = T.unpack $ GH.getUrl $ GH.pullRequestHtmlUrl pull
        issueNumber = show $ GH.unIssueNumber $ GH.pullRequestNumber pull

pullToRichBlock :: GH.PullRequest -> Block
pullToRichBlock pull = Section $ FieldsContent [MarkdownText $ T.pack $ "*タイトル*\n" ++ buildAnchorLink url ("#" ++ issueNumber ++ " " ++ title),MarkdownText $ T.pack $ "*ユーザー*\n" ++ userName]
  where title = T.unpack $ GH.pullRequestTitle pull
        url = T.unpack $ GH.getUrl $ GH.pullRequestHtmlUrl pull
        issueNumber = show $ GH.unIssueNumber $ GH.pullRequestNumber pull
        userName = T.unpack $ GH.untagName  $ GH.simpleUserLogin $ GH.pullRequestUser pull

buildAnchorLink :: String -> String -> String
buildAnchorLink url text = "<" ++ url ++ "|" ++ text ++ ">"
