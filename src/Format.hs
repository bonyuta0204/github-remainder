{-# LANGUAGE OverloadedStrings #-}

module Format
  (
  pullToText,
  pullsToText
  )
where

import qualified Data.Text as T
import qualified GitHub    as GH


pullToText :: GH.PullRequest -> T.Text
pullToText pull = T.pack $ "#" ++ issueNumber ++ " " ++ title ++ "\n" ++ url ++ "\n"
  where title = T.unpack $ GH.pullRequestTitle pull
        url = T.unpack $ GH.getUrl $ GH.pullRequestHtmlUrl pull
        issueNumber = show $ GH.unIssueNumber $ GH.pullRequestNumber pull

pullsToText :: [GH.PullRequest] -> T.Text
pullsToText pulls = T.concat $ fmap pullToText pulls
