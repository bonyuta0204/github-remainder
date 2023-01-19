{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Lib
  ( listOpenPulls,
  listOpenPullDetails,
  filterConfilctPulls,
  formatPulls,
    getToken,
    getPull,
  )
where

import Control.Monad.Trans.Except
import qualified GitHub as GH
import GitHub.Auth
import GitHub.Internal.Prelude
import System.Posix.Env.ByteString
import qualified Data.Vector as V
import qualified Data.Text as T

import Data.Maybe


listOpenPulls :: Auth -> GH.Name GH.Owner -> GH.Name GH.Repo -> ExceptT GH.Error IO (Vector GH.SimplePullRequest)
listOpenPulls auth owner repo = ExceptT $ GH.github auth $ GH.pullRequestsForR owner repo GH.stateOpen GH.FetchAll

getPull :: Auth -> GH.Name GH.Owner -> GH.Name GH.Repo -> GH.IssueNumber -> ExceptT GH.Error IO GH.PullRequest
getPull auth owner repo issueNumber = ExceptT $ GH.github auth $ GH.pullRequestR owner repo issueNumber

listOpenPullDetails :: Auth -> GH.Name GH.Owner -> GH.Name GH.Repo -> ExceptT GH.Error IO (Vector GH.PullRequest)
listOpenPullDetails auth owner repo = do
  pulls <- listOpenPulls auth owner repo
  let issueNumbers = fmap GH.simplePullRequestNumber pulls
  mapM (getPull auth owner repo) issueNumbers



filterConfilctPulls :: Vector GH.PullRequest -> Vector GH.PullRequest
filterConfilctPulls = V.filter ( not . fromMaybe True . GH.pullRequestMergeable )

formatPull :: GH.PullRequest -> Text
formatPull pull = T.concat [GH.pullRequestTitle pull , GH.getUrl $ GH.pullRequestUrl pull]

formatPulls :: Vector GH.PullRequest -> Text
formatPulls pulls = T.concat $ V.toList $ fmap formatPull pulls

getToken :: IO GH.Auth
getToken = do
  token <- getEnv "GITHUB_TOKEN"
  case token of
    Just t -> return $ GH.OAuth t
    Nothing -> return $ GH.OAuth ""
