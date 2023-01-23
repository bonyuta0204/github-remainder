{-# LANGUAGE OverloadedStrings #-}

module Format
  (
  pullToText,
  pullsToText,
  pullToBlock
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
pullToBlock pull = Section $ TextContent $ MarkdownText $ T.pack $ "<" ++ url ++ "|" ++ "#" ++ issueNumber ++ " " ++ title ++ ">"
  where title = T.unpack $ GH.pullRequestTitle pull
        url = T.unpack $ GH.getUrl $ GH.pullRequestHtmlUrl pull
        issueNumber = show $ GH.unIssueNumber $ GH.pullRequestNumber pull
